# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class ProgramNode < Node
      # @rbs @prism_node: Prism::ProgramNode

      attr_reader :prism_node #: Prism::ProgramNode

      # @rbs prism_node: Prism::ProgramNode
      # @rbs return: void
      def initialize(prism_node)
        @prism_node = prism_node
        raise RubyModKit::Error unless prism_node.is_a?(Prism::ProgramNode)

        super()
      end
    end
  end
end
