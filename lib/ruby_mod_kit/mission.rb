# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler mission.
  class Mission
    attr_accessor :offset #: Integer
    attr_reader :modify_script #: String

    # @rbs offset: Integer
    # @rbs modify_script: String
    # @rbs return: void
    def initialize(offset, modify_script)
      @offset = offset
      @modify_script = modify_script
    end

    # @rbs _generation: Generation
    # @rbs _root_node: Node
    # @rbs _parse_result: Prism::ParseResult
    # @rbs _memo: Memo
    # @rbs return: void
    def perform(_generation, _root_node, _parse_result, _memo)
      raise RubyModKit::Error, "Unexpected type #{self.class}"
    end

    # @rbs offset_diff: OffsetDiff
    # @rbs return: void
    def apply(offset_diff)
      @offset = offset_diff[@offset]
    end
  end
end
