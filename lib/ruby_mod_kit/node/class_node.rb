# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class ClassNode < Node
      # @rbs @prism_node: Prism::ClassNode
      # @rbs @body_node: nil | Node::StatementsNode
      # @rbs @parent: Node

      attr_reader :prism_node #: Prism::ClassNode
      attr_reader :body_node #: nil | Node::StatementsNode
      attr_reader :parent #: Node

      # @rbs prism_node: Prism::ClassNode
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::ClassNode)

        super()
      end

      # @rbs child_prism_node: Prism::Node
      # @rbs return: Node
      def wrap(child_prism_node)
        node = super
        @body_node = node if child_prism_node == prism_node.body && node.is_a?(Node::StatementsNode)
        node
      end
    end
  end
end
