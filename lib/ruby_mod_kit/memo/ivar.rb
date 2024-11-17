# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Ivar
      # @rbs @type: String

      attr_reader :type #: String

      # @rbs name: Symbol
      # @rbs return: void
      def initialize(name)
        @name = name
      end

      # @rbs type: String
      # @rbs return: void
      def type=(type)
        @type = Memo.unify_type(type)
      end
    end
  end
end
