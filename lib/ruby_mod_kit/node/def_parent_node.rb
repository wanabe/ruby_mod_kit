# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class DefParentNode < Node::BaseNode
      # @rbs @prism_node: Prism::ClassNode | Prism::ModuleNode
      # @rbs @body_node: nil | Node::StatementsNode
      # @rbs @parent: Node::BaseNode
      # @rbs @prev: Node::BaseNode | nil

      attr_reader :prism_node #: Prism::ClassNode | Prism::ModuleNode
      attr_reader :parent #: Node::BaseNode
      attr_reader :prev #: Node::BaseNode | nil

      # @rbs prism_node: Prism::ClassNode | Prism::ModuleNode
      # @rbs parent: Node::BaseNode
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: void
      def initialize(prism_node, parent:, prev: nil)
        @prism_node = prism_node
        @parent = parent
        @prev = prev
        raise RubyModKit::Error if !prism_node.is_a?(Prism::ClassNode) && !prism_node.is_a?(Prism::ModuleNode)

        super()
      end

      # @rbs prism_child_node: Prism::Node
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: Node::BaseNode
      def wrap(prism_child_node, prev: nil)
        child_node = super
        @body_node = child_node if prism_child_node == @prism_node.body && child_node.is_a?(Node::StatementsNode)
        child_node
      end

      # @rbs return: nil | Node::StatementsNode
      def body_node
        # body_node will be set in #children
        children
        @body_node
      end
    end
  end
end
