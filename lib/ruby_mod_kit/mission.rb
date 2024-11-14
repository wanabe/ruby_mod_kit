# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler mission.
  class Mission
    attr_accessor :offset #: Integer

    # @rbs offset: Integer
    # @rbs return: void
    def initialize(offset)
      @offset = offset
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
    def succ(offset_diff)
      @offset = offset_diff[@offset]
    end
  end
end

require_relative "mission/ivar_arg"
require_relative "mission/type_parameter"
require_relative "mission/type_return"
require_relative "mission/fix_parse_error"
require_relative "mission/overload"
