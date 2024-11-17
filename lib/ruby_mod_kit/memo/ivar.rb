# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Ivar
      # @rbs @type: String

      attr_accessor :type #: String

      # @rbs name: Symbol
      # @rbs return: void
      def initialize(name)
        @name = name
      end
    end
  end
end
