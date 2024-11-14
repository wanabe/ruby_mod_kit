# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Parameter < NodeMemo
      attr_accessor :type #: String

      # @rbs node: Node::ParameterNode
      # @rbs return: void
      def initialize(node)
        @name = node.name
        super
      end
    end
  end
end
