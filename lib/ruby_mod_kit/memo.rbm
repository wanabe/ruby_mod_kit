# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @previous_error_count: Integer
    # @rbs @generation_num: Integer

    attr_accessor :previous_error_count #: Integer
    attr_reader :generation_num #: Integer

    # @rbs return: void
    def initialize
      @previous_error_count = 0
      @generation_num = 0
    end

    # @rbs return: self
    def succ
      @generation_num += 1
      self
    end
  end
end
