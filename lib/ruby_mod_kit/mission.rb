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
    def succ(offset_diff)
      @offset = offset_diff[@offset]
    end

    # @rbs type: String
    # @rbs return: String
    def unify_type(type)
      type[/\A\(([^()]*)\)\z/, 1] || type
    end
  end
end

require "ruby_mod_kit/mission/ivar_arg"
require "ruby_mod_kit/mission/type_parameter"
require "ruby_mod_kit/mission/type_return"
require "ruby_mod_kit/mission/fix_parse_error"
require "ruby_mod_kit/mission/overload"
