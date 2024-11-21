# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @def_parents_memo: Hash[Integer, Memo::DefParentMemo]
    # @rbs @methods_memo: Hash[Integer, Memo::MethodMemo]
    # @rbs @parameters_memo: Hash[Integer, Memo::ParameterMemo]

    attr_reader :def_parents_memo #: Hash[Integer, Memo::DefParentMemo]
    attr_reader :methods_memo #: Hash[Integer, Memo::MethodMemo]
    attr_reader :parameters_memo #: Hash[Integer, Memo::ParameterMemo]

    # @rbs return: void
    def initialize
      @def_parents_memo = {}
      @methods_memo = {}
      @parameters_memo = {}
    end

    # @rbs offset_diff: OffsetDiff
    # @rbs return: void
    def succ(offset_diff)
      [@methods_memo, @parameters_memo, @def_parents_memo].each do |offset_node_memo|
        new_offset_node_memo = {}
        offset_node_memo.each_value do |node_memo|
          node_memo.succ(offset_diff)
          new_offset_node_memo[node_memo.offset] = node_memo
        end
        offset_node_memo.replace(new_offset_node_memo)
      end
      self
    end

    # @rbs def_parent_node: Node::DefParentNode
    # @rbs return: Memo::DefParentMemo
    def def_parent_memo(def_parent_node)
      @def_parents_memo[def_parent_node.offset] ||= Memo::DefParentMemo.new(def_parent_node)
    end

    # @rbs def_node: Node::DefNode
    # @rbs return: Memo::MethodMemo
    def method_memo(def_node)
      @methods_memo[def_node.offset] ||= Memo::MethodMemo.new(def_node)
    end

    # @rbs node: Node
    # @rbs return: Memo::ParameterMemo
    def parameter_memo(node)
      memo = @parameters_memo[node.offset] ||= Memo::ParameterMemo.new(node.offset)
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
require_relative "memo/def_parent_memo"
require_relative "memo/ivar_memo"
require_relative "memo/method_memo"
require_relative "memo/parameter_memo"
