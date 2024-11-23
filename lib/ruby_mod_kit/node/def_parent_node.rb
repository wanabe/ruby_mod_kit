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

      # @rbs return: nil | Node::StatementsNode
      def body_node
        return @body_node if defined?(@body_node)

        body_node = children.find { |node| node.prism_node == @prism_node.body }
        body_node = nil unless body_node.is_a?(Node::StatementsNode)
        @body_node = body_node
      end
    end
  end
end
