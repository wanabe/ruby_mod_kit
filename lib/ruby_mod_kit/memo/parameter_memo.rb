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

      UNTYPED = "untyped"

      # @rbs offset: Integer
      # @rbs return: void
      def initialize(offset)
        @type = UNTYPED
        @ivar_parameter = false
        super
      end

      # @rbs return: bool
      def untyped?
        @type == UNTYPED
      end

      # @rbs type: String
      # @rbs return: void
      def type=(type)
        @type = RubyModKit.unify_type(type)
      end
    end
  end
end
