# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler program node
    class UntypedNode < Node
      attr_reader :prism_node #: Prism::Node

      # @rbs prism_node: Prism::Node
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        super()
      end
    end
  end
end
