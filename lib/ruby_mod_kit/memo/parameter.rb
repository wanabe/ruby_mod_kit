# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Parameter < OffsetMemo
      attr_accessor :type #: String

      # @rbs node: Node::ParameterNode
      # @rbs return: void
      def initialize(node)
        super(node.offset)
      end
    end
  end
end
