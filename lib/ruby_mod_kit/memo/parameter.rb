# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Parameter < NodeMemo
      attr_reader :type #: String

      # @rbs node: Node::ParameterNode
      # @rbs type: String
      # @rbs return: void
      def initialize(node, type)
        @type = type
        @name = node.name
        super(node)
      end
    end
  end
end
