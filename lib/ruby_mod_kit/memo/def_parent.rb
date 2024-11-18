# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for def parent (class, module)
    class DefParent < OffsetMemo
      # @rbs @ivars_memo: Hash[Symbol, Memo::Ivar]

      attr_reader :ivars_memo #: Hash[Symbol, Memo::Ivar]

      # @rbs def_parent_node: Node::DefParentNode
      # @rbs return: void
      def initialize(def_parent_node)
        @ivars_memo = {}
        super(def_parent_node.offset)
      end

      # @rbs name: Symbol
      # @rbs return: Memo::Ivar
      def ivar_memo(name)
        @ivars_memo[name] ||= Memo::Ivar.new(name)
      end
    end
  end
end
