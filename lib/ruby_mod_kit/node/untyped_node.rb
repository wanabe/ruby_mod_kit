# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class UntypedNode < Node::BaseNode
      # @rbs @prism_node: Prism::Node
      # @rbs @parent: Node::BaseNode

      attr_reader :prism_node #: Prism::Node
      attr_reader :parent #: Node::BaseNode

      # @rbs prism_node: Prism::Node
      # @rbs parent: Node::BaseNode
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        super()
      end
    end
  end
end
