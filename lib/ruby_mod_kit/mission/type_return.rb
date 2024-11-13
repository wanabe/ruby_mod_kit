# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class TypeReturn < Mission
      # @rbs offset: Integer
      # @rbs type: String
      # @rbs return: void
      def initialize(offset, type)
        @type = unify_type(type)
        super(offset)
      end

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        def_node = root_node.def_node_at(@offset)
        raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)

        memo.method_memo(def_node).type = @type

        src_offset = parse_result.source.offsets[def_node.location.start_line - 1]
        indent = def_node.offset - src_offset
        generation[src_offset, 0] = "#{" " * indent}# @rbs return: #{@type}\n"
        true
      end
    end
  end
end
