# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The base class for located memo
    class OffsetMemo
      attr_reader :offset #: Integer

      # @rbs offset: Integer
      # @rbs return: void
      def initialize(offset)
        @offset = offset
      end

      # @rbs offset_diff: OffsetDiff
      # @rbs return: void
      def succ(offset_diff)
        @offset = offset_diff[@offset]
      end
    end
  end
end
