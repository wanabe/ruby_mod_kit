# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class DefParentNode < Node::BaseNode
      # @rbs @prism_node: Prism::ClassNode | Prism::ModuleNode
      # @rbs @body_node: nil | Node::StatementsNode
      # @rbs @parent: Node::BaseNode

      attr_reader :prism_node #: Prism::ClassNode | Prism::ModuleNode
      attr_reader :body_node #: nil | Node::StatementsNode
      attr_reader :parent #: Node::BaseNode

      # @rbs prism_node: Prism::ClassNode | Prism::ModuleNode
      # @rbs parent: Node::BaseNode
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error if !prism_node.is_a?(Prism::ClassNode) && !prism_node.is_a?(Prism::ModuleNode)

        super()
      end

      # @rbs child_prism_node: Prism::Node
      # @rbs return: Node::BaseNode
      def wrap(child_prism_node)
        node = super
        @body_node = node if child_prism_node == prism_node.body && node.is_a?(Node::StatementsNode)
        node
      end
    end
  end
end
