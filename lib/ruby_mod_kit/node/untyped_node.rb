# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class UntypedNode < Node::BaseNode
      # @rbs @prism_node: Prism::Node
      # @rbs @parent: Node::BaseNode
      # @rbs @prev: Node::BaseNode | nil

      attr_reader :prism_node #: Prism::Node
      attr_reader :parent #: Node::BaseNode
      attr_reader :prev #: Node::BaseNode | nil

      # @rbs prism_node: Prism::Node
      # @rbs parent: Node::BaseNode
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: void
      def initialize(prism_node, parent:, prev: nil)
        @prism_node = prism_node
        @parent = parent
        @prev = prev
        super()
      end
    end
  end
end
