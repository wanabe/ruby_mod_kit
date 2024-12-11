# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class DefNode < Node::BaseNode
      # @rbs @prism_node: Prism::DefNode
      # @rbs @parent: Node::BaseNode
      # @rbs @prev: Node::BaseNode | nil
      # @rbs @body_node: Node::StatementsNode | Node::BeginNode | nil

      private attr_reader :prism_node #: Prism::DefNode
      attr_reader :parent #: Node::BaseNode
      attr_reader :prev #: Node::BaseNode | nil

      # @rbs prism_node: Prism::DefNode
      # @rbs parent: Node::BaseNode
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: void
      def initialize(prism_node, parent:, prev: nil)
        @prism_node = prism_node
        @parent = parent
        @prev = prev
        raise RubyModKit::Error unless prism_node.is_a?(Prism::DefNode)

        super()
      end

      # @rbs return: Symbol
      def name
        @prism_node.name
      end

      # @rbs return: Prism::Location | nil
      def body_location
        prism_node.body&.location
      end

      # @rbs return: Prism::Location | nil
      def lparen_loc
        @prism_node.lparen_loc
      end

      # @rbs return: Prism::Location | nil
      def rparen_loc
        @prism_node.rparen_loc
      end

      # @rbs return: Prism::Location
      def name_loc
        @prism_node.name_loc
      end

      # @rbs return: Prism::Location | nil
      def end_keyword_loc
        @prism_node.end_keyword_loc
      end

      # @rbs prism_child_node: Prism::Node
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: Node::BaseNode
      def wrap(prism_child_node, prev: nil)
        child_node = super
        if prism_child_node == @prism_node.body
          case child_node
          when Node::StatementsNode, Node::BeginNode
            @body_node = child_node
          end
        end
        child_node
      end

      # @rbs return: Node::StatementsNode | Node::BeginNode | nil
      def body_node
        # body_node will be set in #children
        children
        @body_node
      end
    end
  end
end
