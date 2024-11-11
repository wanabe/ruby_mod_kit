# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The base class for located memo
    class NodeMemo
      attr_reader :offset #: Integer

      # @rbs node: Node
      # @rbs return: void
      def initialize(node)
        @offset = node.offset
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
