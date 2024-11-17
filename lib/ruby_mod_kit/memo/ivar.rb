# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Ivar
      # @rbs @type: String
      # @rbs @attr_kind: nil | Symbol

      attr_reader :type #: String
      attr_reader :attr_kind #: nil | Symbol

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
        else
          raise ArgumentError, "Invalid attribute kind: #{kind}"
        end
      end
    end
  end
end
