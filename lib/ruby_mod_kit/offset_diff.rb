# frozen_string_literal: true

# rbs_inline: enabled

require "sorted_set"

module RubyModKit
  # The class of offset differences.
  class OffsetDiff
    # @rbs @diffs: SortedSet[[Integer, Integer, Integer]]

    # @rbs return: void
    def initialize
      @diffs = SortedSet.new
    end

    # @rbs src_offset: Integer
    # @rbs return: Integer
    def [](src_offset)
      dst_offset = src_offset
      @diffs.each do |(offset, _, diff)|
        break if offset > src_offset
        break if offset == src_offset && diff < 0

        dst_offset += diff
      end
      dst_offset
    end

    # @rbs src_offset: Integer
    # @rbs new_diff: Integer
    # @rbs return: void
    def insert(src_offset, new_diff)
      @diffs << [src_offset, @diffs.size, new_diff]
    end
  end
end
