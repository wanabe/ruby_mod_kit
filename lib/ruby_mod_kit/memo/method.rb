# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Method < OffsetMemo
      # @rbs @name: Symbol
      # @rbs @parameters: Set[Memo::Parameter]
      # @rbs @type: String

      attr_reader :name #: Symbol
      attr_reader :parameters #: Set[Memo::Parameter]
      attr_reader :type #: String

      UNTYPED = "untyped"

      # @rbs node: Node::DefNode
      # @rbs return: void
      def initialize(node)
        @type = UNTYPED
        @parameters = Set.new
        @name = node.name
        raise RubyModKit::Error unless node.parent

        super(node.offset)
      end

      # @rbs parameter_memo: Memo::Parameter
      # @rbs return: Memo::Parameter
      def add_parameter(parameter_memo)
        @parameters << parameter_memo
        parameter_memo
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
