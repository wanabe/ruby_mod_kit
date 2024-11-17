# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @previous_error_messages: Array[String]
    # @rbs @generation_num: Integer
    # @rbs @classes_memo: Hash[Integer, Memo::Class]
    # @rbs @methods_memo: Hash[Integer, Memo::Method]
    # @rbs @parameters_memo: Hash[Integer, Memo::Parameter]

    attr_reader :previous_error_messages #: Array[String]
    attr_reader :generation_num #: Integer
    attr_reader :classes_memo #: Hash[Integer, Memo::Class]
    attr_reader :methods_memo #: Hash[Integer, Memo::Method]
    attr_reader :parameters_memo #: Hash[Integer, Memo::Parameter]

    # @rbs return: void
    def initialize
      @previous_error_messages = []
      @generation_num = 0
      @classes_memo = {}
      @methods_memo = {}
      @parameters_memo = {}
    end

    # @rbs offset_diff: OffsetDiff
    # @rbs previous_error_messages: Array[String]
    # @rbs return: void
    def succ(offset_diff, previous_error_messages)
      @previous_error_messages = previous_error_messages
      [@methods_memo, @parameters_memo, @classes_memo].each do |offset_node_memo|
        new_offset_node_memo = {}
        offset_node_memo.each_value do |node_memo|
          node_memo.succ(offset_diff)
          new_offset_node_memo[node_memo.offset] = node_memo
        end
        offset_node_memo.replace(new_offset_node_memo)
      end
      @generation_num += 1
      self
    end

    # @rbs class_node: Node::ClassNode
    # @rbs return: Memo::Class
    def class_memo(class_node)
      @classes_memo[class_node.offset] ||= Memo::Class.new(class_node)
    end

    # @rbs def_node: Node::DefNode
    # @rbs return: Memo::Method
    def method_memo(def_node)
      @methods_memo[def_node.offset] ||= Memo::Method.new(def_node)
    end

    # @rbs node: Node
    # @rbs return: Memo::Parameter
    def parameter_memo(node)
      memo = @parameters_memo[node.offset] ||= Memo::Parameter.new(node.offset)
      def_node = node.def_node_at(node.offset)
      raise RubyModKit::Error unless def_node.is_a?(Node::DefNode)

      method_memo(def_node).add_parameter(memo)
    end

    class << self
      # @rbs type: String
      # @rbs return: String
      def unify_type(type)
        type[/\A\(([^()]*)\)\z/, 1] || type
      end
    end
  end
end

require_relative "memo/offset_memo"
require_relative "memo/class"
require_relative "memo/ivar"
require_relative "memo/method"
require_relative "memo/parameter"
