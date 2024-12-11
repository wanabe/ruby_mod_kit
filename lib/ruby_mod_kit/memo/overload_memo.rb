# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Memo
    # The memo for parameter type
    class OverloadMemo < OffsetMemo
      # @rbs @name: Symbol
      # @rbs @overload_types: [[Array[String], String]]
      # @rbs @offset_corrected: bool
      # @rbs @offset: Integer

      attr_reader :name #: Symbol
      attr_reader :overload_types #: [[Array[String], String]]

      # @rbs offset: Integer
      # @rbs name: Symbol
      # @rbs return: void
      def initialize(offset, name)
        @name = name
        @overload_types = []
        @offset_corrected = false
        super(offset)
      end

      # @rbs root_node: Node::ProgramNode
      # @rbs return: Integer
      def correct_offset(root_node)
        return @offset if @offset_corrected

        node = root_node.def_node_at(@offset)
        raise RubyModKit::Error unless node.is_a?(Node::DefNode)

        @offset_corrected = true
        @offset = node.offset
      end

      # @rbs parameter_types: Array[String]
      # @rbs return_value_type: String
      # @rbs return: void
      def add_overload_type(parameter_types, return_value_type)
        @overload_types << [parameter_types, return_value_type]
      end
    end
  end
end
