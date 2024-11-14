# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class ParameterNode < Node
      # @rbs @prism_node: (Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode)

      attr_reader :prism_node #: (Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode)

      # @rbs prism_node: Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        case prism_node
        when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
             Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode
          super()
        else
          raise RubyModKit::Error, "unexpected prism node #{prism_node.class}"
        end
      end

      # @rbs return: Symbol
      def name
        @prism_node.name
      end
    end
  end
end
