# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class TypeAttr < Mission
      # @rbs return: void
      def initialize
        super(0)
      end

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        memo.classes_memo.each_value do |class_memo|
          class_node = root_node.class_node_at(class_memo.offset) || raise(RubyModKit::Error)
          class_node.children[-1]&.children&.each do |call_node|
            next unless call_node.is_a?(Node::CallNode)
            next unless %i[attr_reader attr_writer attr_accessor].include?(call_node.name)

            argument_nodes = call_node.children[0].children
            next if argument_nodes.size != 1 || !argument_nodes[0].is_a?(Node::SymbolNode)

            name = argument_nodes[0].value
            ivar_memo = name && class_memo.ivars_memo[name]
            next unless ivar_memo

            line = parse_result.source.lines[call_node.prism_node.location.end_line - 1]
            length = line[/\A\s*(#{call_node.name}\s+:#{name})(?=\n\z)/, 1]&.length
            next unless length

            generation[call_node.location.start_offset + length, 0] = " #: #{ivar_memo.type}"
          end
        end
        true
      end
    end
  end
end
