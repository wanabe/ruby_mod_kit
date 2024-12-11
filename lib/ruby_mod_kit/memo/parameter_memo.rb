# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Memo
    # The memo for parameter type
    class ParameterMemo < OffsetMemo
      # @rbs @type: String
      # @rbs @ivar_parameter: bool
      # @rbs @qualifier: String | nil
      # @rbs @name: Symbol

      attr_reader :type #: String
      attr_accessor :ivar_parameter #: bool
      attr_accessor :qualifier #: String | nil
      attr_accessor :name #: Symbol

      UNTYPED = "untyped" #: String

      # @rbs offset: Integer
      # @rbs return: void
      # @param offset [Integer]
      # @return [void]
      def initialize(offset)
        @type = UNTYPED
        @ivar_parameter = false
        super
      end

      # @rbs return: bool
      # @return [Boolean]
      def untyped?
        @type == UNTYPED
      end

      # @rbs type: String
      # @rbs return: void
      # @param type [String]
      # @return [void]
      def type=(type)
        @type = RubyModKit.unify_type(type)
      end
    end
  end
end
