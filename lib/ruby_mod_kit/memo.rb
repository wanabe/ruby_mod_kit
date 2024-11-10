# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @previous_error_count: Integer
    # @rbs @generation_num: Integer
    # @rbs @overload_methods: Hash[Array[(Integer | Symbol)], Hash[Node, [String]]]

    attr_reader :previous_error_count #: Integer
    attr_reader :generation_num #: Integer
    attr_reader :overload_methods #: Hash[Array[(Integer | Symbol)], Hash[Node, [String]]]

    # @rbs return: void
    def initialize
      @previous_error_count = 0
      @generation_num = 0
      @overload_methods = {}
    end

    # @rbs previous_error_count: Integer
    # @rbs return: self
    def succ(previous_error_count)
      @previous_error_count = previous_error_count
      @generation_num += 1
      self
    end
  end
end
