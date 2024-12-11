# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Memo
    # The memo for parameter type
    class MethodMemo < OffsetMemo
      # @rbs @name: Symbol
      # @rbs @parameters: Set[Memo::ParameterMemo]
      # @rbs @type: String

      attr_reader :name #: Symbol
      attr_reader :parameters #: Set[Memo::ParameterMemo]
      attr_reader :type #: String

      UNTYPED = "untyped" #: String

      # @rbs node: Node::DefNode
      # @rbs return: void
      # @param node [Node::DefNode]
      # @return [void]
      def initialize(node)
        @type = UNTYPED
        @parameters = Set.new
        @name = node.name
        raise RubyModKit::Error unless node.parent

        super(node.offset)
      end

      # @rbs parameter_memo: Memo::ParameterMemo
      # @rbs return: Memo::ParameterMemo
      # @param parameter_memo [Memo::ParameterMemo]
      # @return [Memo::ParameterMemo]
      def add_parameter(parameter_memo)
        @parameters << parameter_memo
        parameter_memo
      end

      # @rbs return: bool
      # @return [Boolean]
      def untyped?
        @type == UNTYPED
      end

      # @rbs type: String
      # @rbs return: void
      # @param type [String]
      # @return [void]
      def type=(type)
        @type = RubyModKit.unify_type(type)
      end
    end
  end
end
