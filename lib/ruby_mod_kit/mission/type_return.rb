# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"
require "ruby_mod_kit/memo"

module RubyModKit
  class Mission
    # The mission for parameter types
    class TypeReturn < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        def_node = root_node[@offset, Prism::DefNode]
        raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.prism_node.is_a?(Prism::DefNode)

        method_memo = memo.methods_memo[def_node.offset] || Memo::Method.new(memo, def_node)
        method_memo.type = @modify_script

        src_offset = parse_result.source.offsets[def_node.prism_node.location.start_line - 1]
        indent = def_node.offset - src_offset
        generation[src_offset, 0] = "#{" " * indent}# @rbs return: #{@modify_script}\n"
        true
      end
    end
  end
end