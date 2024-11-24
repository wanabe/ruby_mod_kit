# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The base class of transpiler mission.
  class Mission
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
    def succ(offset_diff); end
  end
end
