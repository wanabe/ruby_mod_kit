# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Class < OffsetMemo
      # @rbs @ivars_memo: Hash[Symbol, Memo::Ivar]

      attr_reader :ivars_memo #: Hash[Symbol, Memo::Ivar]

      # @rbs class_node: Node::ClassNode
      # @rbs return: void
      def initialize(class_node)
        @ivars_memo = {}
        super(class_node.offset)
      end

      # @rbs name: Symbol
      # @rbs return: Memo::Ivar
      def ivar_memo(name)
        @ivars_memo[name] ||= Memo::Ivar.new(name)
      end
    end
  end
end
