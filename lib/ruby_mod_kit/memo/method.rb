# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Method < NodeMemo
      # @rbs @parent_offset: Integer
      # @rbs @name: Symbol
      # @rbs @parameters: Array[Parameter]
      # @rbs @type: String

      attr_reader :parent_offset #: Integer
      attr_reader :name #: Symbol
      attr_reader :parameters #: Array[Parameter]
      attr_accessor :type #: String

      # @rbs node: Node
      # @rbs return: void
      def initialize(node)
        @type = "untyped"
        @parameters = []
        @name = node.name
        raise RubyModKit::Error unless node.parent

        @parent_offset = node.parent.offset
        super
      end

      # @rbs parameter_memo: Parameter
      # @rbs return: Memo::Parameter
      def add_parameter(parameter_memo)
        @parameters << parameter_memo
        parameter_memo
      end
    end
  end
end
