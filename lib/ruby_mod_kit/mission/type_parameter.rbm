# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class TypeParameter < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        def_node = root_node[@offset, Prism::DefNode]
        raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.prism_node.is_a?(Prism::DefNode)

        parameter_node = root_node[@offset]
        raise RubyModKit::Error, "ParameterNode not found" unless parameter_node

        Memo::Parameter.new(memo, parameter_node, @modify_script)
        src_offset = parse_result.source.offsets[def_node.prism_node.location.start_line - 1]
        indent = def_node.offset - src_offset
        generation[src_offset, 0] = "#{" " * indent}# @rbs #{parameter_node.name}: #{@modify_script}\n"
        true
      end
    end
  end
end
