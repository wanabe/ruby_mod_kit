# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Memo
    # The memo for parameter type
    class Parameter < NodeMemo
      attr_reader :type #: String

      # @rbs memo: Memo
      # @rbs node: Node
      # @rbs type: String
      # @rbs return: void
      def initialize(memo, node, type)
        @type = type
        @name = node.name

        def_node = node.parent&.parent
        raise RubyModKit::Error unless def_node

        @method = memo.methods_memo[def_node.offset] || Memo::Method.new(memo, def_node)
        @method.add_parameter(self)

        memo.parameters_memo[node.offset] = self
        super(node)
      end
    end
  end
end
