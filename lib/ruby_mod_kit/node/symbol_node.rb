# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class SymbolNode < Node::BaseNode
      # @rbs @prism_node: Prism::SymbolNode
      # @rbs @parent: Node::BaseNode
      # @rbs @prev: Node::BaseNode | nil
      # @rbs @value: Symbol | nil

      private attr_reader :prism_node #: Prism::SymbolNode
      attr_reader :parent #: Node::BaseNode
      attr_reader :prev #: Node::BaseNode | nil

      # @rbs prism_node: Prism::SymbolNode
      # @rbs parent: Node::BaseNode
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: void
      # @param prism_node [Prism::SymbolNode]
      # @param parent [Node::BaseNode]
      # @param prev [Node::BaseNode, nil]
      # @return [void]
      def initialize(prism_node, parent:, prev: nil)
        @prism_node = prism_node
        @parent = parent
        @prev = prev
        raise RubyModKit::Error unless prism_node.is_a?(Prism::SymbolNode)

        super()
      end

      # @rbs return: Symbol | nil
      # @return [Symbol, nil]
      def value
        return @value if defined?(@value)

        @value = @prism_node.value&.to_sym
      end
    end
  end
end
