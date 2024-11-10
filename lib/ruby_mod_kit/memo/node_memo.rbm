# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The base class for located memo
    class NodeMemo
      attr_reader :offset #: Integer

      # @rbs memo: Memo
      # @rbs node: Node
      # @rbs return: void
      def initialize(memo, node)
        @offset = node.offset
        memo.add(type, node, self)
      end

      # @rbs return: Symbol
      def type
        :unknown
      end

      # @rbs offset_diff: OffsetDiff
      # @rbs return: void
      def succ(offset_diff)
        @offset = offset_diff[@offset]
      end
    end
  end
end

require "ruby_mod_kit/memo/method"
require "ruby_mod_kit/memo/parameter"
