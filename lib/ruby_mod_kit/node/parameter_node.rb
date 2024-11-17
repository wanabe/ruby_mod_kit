# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class ParameterNode < Node
      # @rbs!
      #   type prism_node = Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode
      #                   | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode
      #                   | Prism::RestParameterNode

      # @rbs @prism_node: prism_node
      # @rbs @parent: Node

      attr_reader :prism_node #: prism_node
      attr_reader :parent #: Node

      # @rbs prism_node: prism_node
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        case prism_node
        when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
             Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode,
             Prism::RestParameterNode
          super()
        else
          raise RubyModKit::Error, "unexpected prism node #{prism_node.class}"
        end
      end

      # @rbs return: Symbol | nil
      def name
        @prism_node.name
      end
    end
  end
end
