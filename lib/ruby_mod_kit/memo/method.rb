# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Method < OffsetMemo
      UNTYPED = "untyped"

      # @rbs @parent_offset: Integer
      # @rbs @name: Symbol
      # @rbs @parameters: Set[Parameter]
      # @rbs @type: String

      attr_reader :parent_offset #: Integer
      attr_reader :name #: Symbol
      attr_reader :parameters #: Set[Parameter]
      attr_reader :type #: String

      # @rbs node: Node::DefNode
      # @rbs return: void
      def initialize(node)
        @type = UNTYPED
        @parameters = Set.new
        @name = node.name
        raise RubyModKit::Error unless node.parent

        @parent_offset = node.parent.offset
        super(node.offset)
      end

      # @rbs parameter_memo: Parameter
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
