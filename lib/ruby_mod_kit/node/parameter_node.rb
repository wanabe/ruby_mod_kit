# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class ParameterNode < Node::BaseNode
      # @rbs!
      #   type prism_node = Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode
      #                   | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode
      #                   | Prism::RestParameterNode

      # @rbs @prism_node: prism_node
      # @rbs @parent: Node::BaseNode

      attr_reader :prism_node #: prism_node
      attr_reader :parent #: Node::BaseNode

      # @rbs prism_node: prism_node
      # @rbs parent: Node::BaseNode
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
