# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class ModuleNode < Node
      # @rbs @prism_node: Prism::ModuleNode

      attr_reader :prism_node #: Prism::ModuleNode

      # @rbs prism_node: Prism::ModuleNode
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::ModuleNode)

        super()
      end
    end
  end
end
