require_relative "./leftovers/version"
require_relative "./leftovers/definition"
require_relative "./leftovers/argument_rule"
require_relative "./leftovers/rule"
require_relative "./leftovers/collector"
require_relative "./leftovers/file_list"
require_relative "./leftovers/merged_config"
require_relative "./leftovers/config"
require_relative "./leftovers/reporter"

module Leftovers
  module_function

  def config
    @config ||= Leftovers::MergedConfig.new
  end

  def collector
    @collector ||= Leftovers::Collector.new
  end

  def reporter
    @reporter ||= Leftovers::Reporter.new
  end

  def leftovers
    @leftovers ||= begin
      collector.collect
      leftovers = collector.definitions.reject do |definition|
        definition.any_skipped? || definition.any_in_collection?
      end
    end
  end

  def run
    reset
    return 0 if leftovers.empty?

    only_test = []
    none = []
    leftovers.sort.each do |definition|
      if !definition.test? && definition.any_in_test_collection?
        only_test << definition
      else
        none << definition
      end
    end

    unless only_test.empty?
      puts "\e[31mOnly directly called in tests:\e[0m"
      only_test.each { |definition| reporter.call(definition) }
    end

    unless none.empty?
      puts "\e[31mNot directly called at all:\e[0m"
      none.each { |definition| reporter.call(definition) }
    end

    1
  end

  def reset
    remove_instance_variable(:@config) if defined?(@config)
    remove_instance_variable(:@collector) if defined?(@collector)
    remove_instance_variable(:@reporter) if defined?(@reporter)
    remove_instance_variable(:@leftovers) if defined?(@leftovers)
    remove_instance_variable(:@try_require) if defined?(@try_require)
  end

  def warn(message)
    $stderr.puts("\e[2K#{message}")
  end

  def try_require(requirable, message = nil)
    @try_require ||= {}
    return @try_require[requirable] if @try_require.key?(requirable)
    @try_require[requirable] = require requirable
  rescue LoadError
    warn message if message
    @try_require[requirable] = false
  end

  def wrap_array(value)
    case value
    when Hash
      [value]
    when Array
      value
    else
      Array(value)
    end
  end
end
