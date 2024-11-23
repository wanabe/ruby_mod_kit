# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class SymbolNode < Node::BaseNode
      # @rbs @prism_node: Prism::SymbolNode
      # @rbs @parent: Node::BaseNode

      attr_reader :prism_node #: Prism::SymbolNode
      attr_reader :parent #: Node::BaseNode

      # @rbs prism_node: Prism::SymbolNode
      # @rbs parent: Node::BaseNode
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::SymbolNode)

        super()
      end

      # @rbs return: nil | Symbol
      def value
        return @value if defined?(@value)

        @value = @prism_node.value&.to_sym
      end
    end
  end
end
