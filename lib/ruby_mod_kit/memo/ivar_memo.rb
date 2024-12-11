# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Memo
    # The memo for parameter type
    class IvarMemo
      # @rbs @type: String | nil
      # @rbs @attr_kind: Symbol | nil
      # @rbs @offset: Integer | nil
      # @rbs @indent: String
      # @rbs @name: Symbol
      # @rbs @visibility: Symbol | nil
      # @rbs @separator: String

      attr_reader :type #: String | nil
      attr_reader :attr_kind #: Symbol | nil
      attr_accessor :offset #: Integer | nil
      attr_accessor :indent #: String
      attr_accessor :visibility #: Symbol | nil
      attr_accessor :separator #: String

      # @rbs name: Symbol
      # @rbs return: void
      # @param name [Symbol]
      # @return [void]
      def initialize(name)
        @name = name
        @indent = ""
      end

      # @rbs type: String
      # @rbs return: void
      # @param type [String]
      # @return [void]
      def type=(type)
        @type = RubyModKit.unify_type(type)
      end

      # @rbs kind: Symbol | String
      # @rbs return: void
      # @param kind [Symbol, String]
      # @return [void]
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
      # @param offset_diff [OffsetDiff]
      # @return [void]
      def succ(offset_diff)
        offset = @offset
        return unless offset

        @offset = offset_diff[offset]
      end
    end
  end
end
