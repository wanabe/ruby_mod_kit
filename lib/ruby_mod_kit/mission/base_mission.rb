# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Mission
    # The base class of transpiler mission.
    class BaseMission
      # @rbs @offset: Integer

      attr_accessor :offset #: Integer

      # @rbs offset: Integer
      # @rbs return: void
      def initialize(offset)
        @offset = offset
      end

      # @rbs _generation: Generation
      # @rbs _root_node: Node::ProgramNode
      # @rbs _parse_result: Prism::ParseResult
      # @rbs _memo_pad: MemoPad
      # @rbs return: void
      def perform(_generation, _root_node, _parse_result, _memo_pad)
        raise RubyModKit::Error, "Unexpected type #{self.class}"
      end

      # @rbs offset_diff: OffsetDiff
      # @rbs return: void
      def succ(offset_diff)
        @offset = offset_diff[@offset]
      end
    end
  end
end
