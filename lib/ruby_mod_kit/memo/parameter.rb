# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Parameter < OffsetMemo
      UNTYPED = "untyped"

      # @rbs @type: String
      # @rbs @ivar_parameter: bool
      # @rbs @qualifier: String

      attr_reader :type #: String
      attr_accessor :ivar_parameter #: bool
      attr_accessor :qualifier #: String

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
        @type = Memo.unify_type(type)
      end
    end
  end
end
