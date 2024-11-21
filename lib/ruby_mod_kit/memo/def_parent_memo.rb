# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for def parent (class, module)
    class DefParentMemo < OffsetMemo
      # @rbs @ivars_memo: Hash[Symbol, Memo::IvarMemo]

      attr_reader :ivars_memo #: Hash[Symbol, Memo::IvarMemo]

      # @rbs def_parent_node: Node::DefParentNode
      # @rbs return: void
      def initialize(def_parent_node)
        @ivars_memo = {}
        super(def_parent_node.offset)
      end

      # @rbs name: Symbol
      # @rbs return: Memo::IvarMemo
      def ivar_memo(name)
        @ivars_memo[name] ||= Memo::IvarMemo.new(name)
      end
    end
  end
end
