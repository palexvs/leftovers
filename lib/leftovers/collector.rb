# frozen_string_literal: true

require 'fast_ignore'
require 'set'
require 'parallel'
require_relative 'file_collector'
require_relative 'file_list'

module Leftovers
  class Collector
    attr_reader :calls
    attr_reader :test_calls
    attr_reader :definitions

    def initialize # rubocop:disable Metrics/MethodLength
      @calls = []
      @test_calls = []
      @definitions = []
      @count = 0
      @count_calls = 0
      @count_definitions = 0
    end

    def collect
      collect_file_list(Leftovers::FileList.new)

      Leftovers.newline
      @calls = @calls.to_set.freeze
      @test_calls = @test_calls.to_set.freeze
    end

    def collect_file_list(list)
      if Leftovers.parallel?
        Parallel.each(list, finish: method(:finish_parallel), &method(:collect_file))
      else
        list.each { |filename| finish_parallel(nil, nil, collect_file(filename)) }
      end
    end

    def collect_file(filename)
      file_collector = Leftovers::FileCollector.new(filename)
      file_collector.collect

      file_collector.to_h
    end

    def finish_parallel(_, _, result) # rubocop:disable Metrics/MethodLength
      Leftovers.print "checked #{@count += 1} files, collected #{@count_calls += result[:calls].length} calls, #{@count_definitions += result[:definitions].length} definitions\r" # rubocop:disable Layout/LineLength
      if result[:test?]
        @test_calls.concat(result[:calls])
      else
        @calls.concat(result[:calls])
      end

      @definitions.concat(result[:definitions])
    end
  end
end
