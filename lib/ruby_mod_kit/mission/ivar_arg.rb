# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for instance variable arguments
    class IvarArg < Mission
      attr_reader :assignment #: String

      # @rbs offset: Integer
      # @rbs assignment: String
      # @rbs return: void
      def initialize(offset, assignment)
        @assignment = assignment
        super(offset)
      end

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs _parse_result: Prism::ParseResult
      # @rbs _memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, _parse_result, _memo)
        def_node = root_node.def_node_at(@offset)
        raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)

        def_body_location = def_node.body_location
        end_loc = def_node.end_keyword_loc
        if def_body_location
          indent = def_body_location.start_column
          src_offset = def_body_location.start_offset - indent
        elsif end_loc
          indent = end_loc.start_column + 2
          src_offset = end_loc.start_offset - indent + 2
        end
        raise RubyModKit::Error if !src_offset || !indent

        generation[src_offset, 0] = "#{" " * indent}#{@assignment}\n"
        true
      end
    end
  end
end
