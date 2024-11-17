# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class SymbolNode < Node
      # @rbs @prism_node: Prism::SymbolNode

      attr_reader :prism_node #: Prism::SymbolNode

      # @rbs prism_node: Prism::SymbolNode
      # @rbs parent: Node
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
