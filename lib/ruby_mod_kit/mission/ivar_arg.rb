# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"

module RubyModKit
  class Mission
    # The mission for instance variable arguments
    class IvarArg < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs _parse_result: Prism::ParseResult
      # @rbs return: void
      def perform(generation, root_node, _parse_result)
        def_node = root_node[@offset, Prism::DefNode]
        raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.prism_node.is_a?(Prism::DefNode)

        def_body_location = def_node.prism_node.body&.location
        if def_body_location
          indent = def_body_location.start_column
          src_offset = def_body_location.start_offset - indent
        elsif def_node.prism_node.end_keyword_loc
          indent = def_node.prism_node.end_keyword_loc.start_column + 2
          src_offset = def_node.prism_node.end_keyword_loc.start_offset - indent + 2
        else
          raise RubyModKit::Error, "Invalid DefNode #{def_node.prism_node.inspect}"
        end

        generation[src_offset, 0] = "#{" " * indent}#{@modify_script}\n"
      end
    end
  end
end
