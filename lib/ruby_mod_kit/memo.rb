# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/memo/node_memo"

module RubyModKit
  # The class of transpiler generation.
  class Memo
    # @rbs @previous_error_count: Integer
    # @rbs @generation_num: Integer
    # @rbs @overload_methods: Hash[Array[(Integer | Symbol)], Hash[Node, [String]]]

    attr_reader :previous_error_count #: Integer
    attr_reader :generation_num #: Integer
    attr_reader :overload_methods #: Hash[Array[(Integer | Symbol)], Hash[Node, [String]]]

    # @rbs return: void
    def initialize
      @previous_error_count = 0
      @generation_num = 0
      @overload_methods = {}
      @type_map = {}
    end

    # @rbs offset_diff: OffsetDiff
    # @rbs previous_error_count: Integer
    # @rbs return: void
    def succ(offset_diff, previous_error_count)
      @previous_error_count = previous_error_count
      @type_map.each_value do |offset_node_memo|
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

    # @rbs type: Symbol
    # @rbs offset: Integer
    # @rbs return: NodeMemo | nil
    def [](type, offset)
      @type_map[type] ||= {}
      @type_map[type][offset]
    end

    # @rbs type: Symbol
    # @rbs node: Node
    # @rbs node_memo: NodeMemo
    # @rbs return: NodeMemo
    def add(type, node, node_memo)
      @type_map[type] ||= {}
      @type_map[type][node.offset] = node_memo
    end
  end
end
