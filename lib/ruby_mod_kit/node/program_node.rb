# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # Transpiler program node
    class ProgramNode < Node::BaseNode
      # @rbs @prism_node: Prism::ProgramNode

      attr_reader :prism_node #: Prism::ProgramNode

      # @rbs prism_node: Prism::ProgramNode
      # @rbs return: void
      def initialize(prism_node)
        @prism_node = prism_node
        raise RubyModKit::Error unless prism_node.is_a?(Prism::ProgramNode)

        super()
      end

      # @rbs return: nil
      def parent
        nil
      end
    end
  end
end
