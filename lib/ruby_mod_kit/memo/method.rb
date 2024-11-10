# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Method < NodeMemo
      # @rbs return: Symbol
      def type
        :method
      end

      # @rbs memo: Memo
      # @rbs node: Node
      # @rbs type: String
      # @rbs return: void
      def initialize(memo, node)
        @name = node.name
        raise RubyModKit::Error unless node.parent

        @parent_offset = node.parent.offset
        super
      end
    end
  end
end
