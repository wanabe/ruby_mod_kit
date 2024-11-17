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
          ivars_memo = class_memo.ivars_memo.dup
          class_node = root_node.class_node_at(class_memo.offset) || raise(RubyModKit::Error)
          attr_adding_line = 0
          indent = nil
          class_node.body_node&.children&.each do |call_node|
            break if ivars_memo.empty?
            next unless call_node.is_a?(Node::CallNode)
            next unless %i[attr_reader attr_writer attr_accessor].include?(call_node.name)

            indent ||= parse_result.source.lines[call_node.prism_node.location.start_line - 1][/\A\s*/] || ""
            attr_adding_line = call_node.prism_node.location.end_line
            argument_nodes = call_node.children[0].children
            next if argument_nodes.size != 1 || !argument_nodes[0].is_a?(Node::SymbolNode)

            name = argument_nodes[0].value || next
            ivar_memo = ivars_memo.delete(name) || next
            line = parse_result.source.lines[call_node.prism_node.location.end_line - 1]
            length = line[/\A\s*(#{call_node.name}\s+:#{name})(?=\n\z)/, 1]&.length || next
            generation[call_node.location.start_offset + length, 0] = " #: #{ivar_memo.type}"
          end

          ivars_memo.keep_if { |_, ivar_memo| ivar_memo.attr_kind }
          next if ivars_memo.empty?

          add_first_separator_line = false
          if attr_adding_line == 0
            attr_adding_line = class_node.prism_node.location.start_line
            prev_line = nil
            while parse_result.source.lines[attr_adding_line] =~ /\A\s*#.*|\A$/
              prev_line = ::Regexp.last_match(0)
              attr_adding_line += 1
            end
            add_first_separator_line = prev_line != ""
          end
          line = parse_result.source.lines[attr_adding_line] || next
          add_separator_line = line != "\n" && line !~ /\A\s*end$/
          offset = parse_result.source.offsets[attr_adding_line] || next

          unless indent
            if class_node.body_node
              first_line = parse_result.source.lines[class_node.body_node.prism_node.location.start_line - 1]
              indent = first_line[/\A\s*/] || raise(RubyModKit::Error)
            else
              class_line = parse_result.source.lines[class_node.prism_node.location.start_line - 1]
              indent = "  #{class_line[/\A\s*/]}"
            end
          end

          generation[offset, 0] = "\n" if add_first_separator_line
          ivars_memo.each do |name, ivar_memo|
            generation[offset, 0] = "#{indent}#{ivar_memo.attr_kind} :#{name} #: #{ivar_memo.type}\n"
          end
          generation[offset, 0] = "\n" if add_separator_line
        end
        true
      end
    end
  end
end
