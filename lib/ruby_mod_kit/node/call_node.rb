# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Node
    # Transpiler method call node
    class CallNode < Node
      # @rbs @prism_node: Prism::CallNode
      # @rbs @name: Symbol

      attr_reader :prism_node #: Prism::CallNode
      attr_reader :name #: Symbol

      # @rbs prism_node: Prism::CallNode
      # @rbs parent: Node
      # @rbs return: void
      def initialize(prism_node, parent:)
        @prism_node = prism_node
        @parent = parent
        raise RubyModKit::Error unless prism_node.is_a?(Prism::CallNode)

        @name = prism_node.name.to_sym
        super()
      end
    end
  end
end