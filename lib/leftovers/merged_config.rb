# frozen_string_literal: true

require 'set'
require 'fast_ignore'

module Leftovers
  class MergedConfig
    MEMOIZED_IVARS = %i{
      @exclude_paths
      @include_paths
      @test_paths
      @precompilers
      @dynamic
      @keep
      @test_only
    }.freeze

    def initialize(load_defaults: false)
      @configs = []
      @loaded_configs = Set.new
      return unless load_defaults

      self << :ruby
      self << :leftovers
      self << project_config
      self << project_todo
      load_bundled_gem_config
    end

    def <<(config)
      config = Leftovers::Config.new(config) unless config.is_a?(Leftovers::Config)
      return if @loaded_configs.include?(config.name)

      unmemoize
      @configs << config
      @loaded_configs << config.name
      config.gems.each { |gem| self << gem }
      require_requires(config)
    end

    def exclude_paths
      @exclude_paths ||= @configs.flat_map(&:exclude_paths)
    end

    def include_paths
      @include_paths ||= @configs.flat_map(&:include_paths)
    end

    def test_paths
      @test_paths ||= Leftovers::MatcherBuilders::Path.build(@configs.flat_map(&:test_paths))
    end

    def precompilers
      @precompilers ||= Leftovers::Precompilers.build(@configs.flat_map(&:precompile))
    end

    def dynamic
      @dynamic ||= ::Leftovers::ProcessorBuilders::Each.build(@configs.map(&:dynamic))
    end

    def keep
      @keep ||= ::Leftovers::MatcherBuilders::Or.build(@configs.map(&:keep))
    end

    def test_only
      @test_only ||= ::Leftovers::MatcherBuilders::Or.build(@configs.map(&:test_only))
    end

    private

    def project_config
      Leftovers::Config.new(:'.leftovers.yml', path: Leftovers.pwd + '.leftovers.yml')
    end

    def project_todo
      Leftovers::Config.new(:'.leftovers_todo.yml', path: Leftovers.pwd + '.leftovers_todo.yml')
    end

    def unmemoize
      MEMOIZED_IVARS.each do |ivar|
        remove_instance_variable(ivar) if instance_variable_get(ivar)
      end
    end

    def require_requires(config)
      config.requires.each do |req|
        if req.is_a?(Hash) && req[:quiet]
          Leftovers.try_require(req[:quiet])
        else
          Leftovers.try_require(req, message: "cannot require '#{req}' from #{config.name}.yml")
        end
      end
    end

    def load_bundled_gem_config
      return unless Leftovers.try_require('bundler')

      Bundler.locked_gems.specs.each do |spec|
        self << spec.name
      end
    end
  end
end
