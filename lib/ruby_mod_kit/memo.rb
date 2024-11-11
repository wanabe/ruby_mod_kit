# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/memo/node_memo"

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @previous_error_count: Integer
    # @rbs @generation_num: Integer
    # @rbs @methods_memo: Hash[Integer, Memo::Method]
    # @rbs @parameters_memo: Hash[Integer, Memo::Parameter]

    attr_reader :previous_error_count #: Integer
    attr_reader :generation_num #: Integer
    attr_reader :methods_memo #: Hash[Integer, Memo::Method]
    attr_reader :parameters_memo #: Hash[Integer, Memo::Parameter]

    # @rbs return: void
    def initialize
      @previous_error_count = 0
      @generation_num = 0
      @methods_memo = {}
      @parameters_memo = {}
    end

    # @rbs offset_diff: OffsetDiff
    # @rbs previous_error_count: Integer
    # @rbs return: void
    def succ(offset_diff, previous_error_count)
      @previous_error_count = previous_error_count
      [@methods_memo, @parameters_memo].each do |offset_node_memo|
        new_offset_node_memo = {}
        offset_node_memo.each_value do |node_memo|
          node_memo.succ(offset_diff)
          new_offset_node_memo[node_memo.offset] = node_memo
        end
        offset_node_memo.replace(new_offset_node_memo)
      end
      @generation_num += 1
      self
    end
  end
end
