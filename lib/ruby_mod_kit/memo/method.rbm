# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Method < NodeMemo
      # @rbs @parent_offset: Integer
      # @rbs @name: Symbol
      # @rbs @parameters: Array[Parameter]

      attr_reader :parent_offset #: Integer
      attr_reader :name #: Symbol
      attr_reader :parameters #: Array[Parameter]

      # @rbs memo: Memo
      # @rbs node: Node
      # @rbs type: String
      # @rbs return: void
      def initialize(memo, node)
        @parameters = []
        @name = node.name
        raise RubyModKit::Error unless node.parent

        @parent_offset = node.parent.offset
        memo.methods_memo[node.offset] = self
        super(node)
      end

      # @rbs parameter_memo: Parameter
      # @rbs return: void
      def add_parameter(parameter_memo)
        @parameters << parameter_memo
      end
    end
  end
end
