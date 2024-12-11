# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of offset differences.
  class OffsetDiff
    # @rbs @diffs: Hash[Integer, Integer]
    # @rbs @offsets: Array[Integer]

    # @rbs return: void
    # @return [void]
    def initialize
      @diffs = {}
      @offsets = []
    end

    # @rbs src_offset: Integer
    # @rbs return: Integer
    # @param src_offset [Integer]
    # @return [Integer]
    def [](src_offset)
      dst_offset = src_offset
      @offsets.each do |offset|
        diff = @diffs[offset]
        break if offset > src_offset
        break if offset == src_offset && diff < 0

        dst_offset += diff
      end
      dst_offset
    end

    # @rbs src_offset: Integer
    # @rbs new_diff: Integer
    # @rbs return: void
    # @param src_offset [Integer]
    # @param new_diff [Integer]
    # @return [void]
    def insert(src_offset, new_diff)
      if @diffs[src_offset]
        @diffs[src_offset] += new_diff
      else
        @diffs[src_offset] = new_diff
        @offsets.insert(@offsets.bsearch_index { _1 > src_offset } || -1, src_offset)
      end
    end
  end
end
