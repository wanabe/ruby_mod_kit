# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler mission.
  class Mission
    # @rbs @offset: Integer

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

require_relative "mission/instance_variable_parameter_mission"
require_relative "mission/type_attr_mission"
require_relative "mission/type_parameter_mission"
require_relative "mission/type_return_mission"
require_relative "mission/fix_parse_error_mission"
require_relative "mission/overload_mission"
