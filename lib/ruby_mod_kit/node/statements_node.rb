# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class StatementsNode < Node::BaseNode
      # @rbs @prism_node: Prism::StatementsNode
      # @rbs @parent: Node::BaseNode

      attr_reader :prism_node #: Prism::StatementsNode
      attr_reader :parent #: Node::BaseNode

      # @rbs prism_node: Prism::StatementsNode
      # @rbs parent: Node::BaseNode
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::StatementsNode)

        super()
      end
    end
  end
end
