# frozen-string-literal: true

module Leftovers
  module DynamicProcessors
    class Call
      def initialize(matcher, processor)
        @matcher = matcher
        @processor = processor
      end

      def process(node, file)
        return unless @matcher === node

        calls = @processor.process(nil, node, node)

        ::Leftovers.each_or_self(calls) do |call|
          file.calls << call
        end
      end
    end
  end
end
