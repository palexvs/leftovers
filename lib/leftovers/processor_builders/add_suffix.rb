# frozen_string_literal: true

module Leftovers
  module ProcessorBuilders
    module AddSuffix
      class << self
        def build(argument, then_processor)
          case argument
          when ::Hash then build_hash(argument, then_processor)
          when ::String then ::Leftovers::Processors::AddSuffix.new(argument, then_processor)
            # :nocov:
          else raise Leftovers::UnexpectedCase, "Unhandled value #{argument.inspect}"
            # :nocov:
          end
        end

        private

        def build_hash(argument, then_processor)
          dynamic_suffix = ::Leftovers::ProcessorBuilders::Action.build(
            argument, ::Leftovers::Processors::AppendSym
          )
          ::Leftovers::Processors::AddDynamicSuffix.new(dynamic_suffix, then_processor)
        end
      end
    end
  end
end
