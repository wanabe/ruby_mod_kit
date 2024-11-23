# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Memo
    # The memo for parameter type
    class IvarMemo
      # @rbs @type: nil | String
      # @rbs @attr_kind: nil | Symbol
      # @rbs @offset: nil | Integer
      # @rbs @indent: String
      # @rbs @name: Symbol

      attr_reader :type #: nil | String
      attr_reader :attr_kind #: nil | Symbol
      attr_accessor :offset #: nil | Integer
      attr_accessor :indent #: String

      # @rbs name: Symbol
      # @rbs return: void
      def initialize(name)
        @name = name
        @indent = ""
      end

      # @rbs type: String
      # @rbs return: void
      def type=(type)
        @type = RubyModKit.unify_type(type)
      end

      # @rbs kind: Symbol | String
      # @rbs return: void
      def attr_kind=(kind)
        case kind.to_sym
        when :attr_reader, :reader, :getter
          @attr_kind = :attr_reader
        when :attr_writer, :writer, :setter
          @attr_kind = :attr_writer
        when :attr_accessor, :accessor, :property
          @attr_kind = :attr_accessor
        end
      end

      # @rbs offset_diff: OffsetDiff
      # @rbs return: void
      def succ(offset_diff)
        offset = @offset
        return unless offset

        @offset = offset_diff[offset]
      end
    end
  end
end
