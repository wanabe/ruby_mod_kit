# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class DefNode < Node
      attr_reader :prism_node #: Prism::DefNode

      # @rbs prism_node: Prism::DefNode
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::DefNode)

        super()
      end

      # @rbs return: Symbol
      def name
        @prism_node.name
      end
    end
  end
end
