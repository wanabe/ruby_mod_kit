# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class TypeAttrMission < Mission
      # @rbs return: void
      def initialize
        super(0)
      end

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs _parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, _parse_result, memo)
        memo.def_parents_memo.each_value do |def_parent_memo|
          ivars_memo = def_parent_memo.ivars_memo.dup
          def_parent_node = root_node.def_parent_node_at(def_parent_memo.offset) || raise(RubyModKit::Error)
          attr_adding_line = 0
          def_parent_node.body_node&.children&.each do |call_node|
            break if ivars_memo.empty?
            next unless call_node.is_a?(Node::CallNode)
            next unless %i[attr_reader attr_writer attr_accessor].include?(call_node.name)

            attr_adding_line = call_node.location.end_line
            argument_nodes = call_node.children[0].children
            next if argument_nodes.size != 1 || !argument_nodes[0].is_a?(Node::SymbolNode)

            name = argument_nodes[0].value || next
            ivar_memo = ivars_memo.delete(name) || next
            line = generation.line(call_node)
            length = line[/\A\s*(#{call_node.name}\s+:#{name})(?=\n\z)/, 1]&.length || next
            generation[call_node.location.start_offset + length, 0] = " #: #{ivar_memo.type}"
          end

          ivars_memo.keep_if { |_, ivar_memo| ivar_memo.attr_kind }
          next if ivars_memo.empty?

          add_first_separator_line = false
          if attr_adding_line == 0
            attr_adding_line = def_parent_node.location.start_line
            prev_line = nil
            while generation.line(attr_adding_line) =~ /\A\s*#.*|\A$/
              prev_line = ::Regexp.last_match(0)
              attr_adding_line += 1
            end
            add_first_separator_line = prev_line != ""
          end
          line = generation.line(attr_adding_line) || next
          add_separator_line = line != "\n" && line !~ /\A\s*end$/
          offset = generation.src_offset(attr_adding_line) || next

          if def_parent_node.body_node
            first_line = generation.line(def_parent_node.body_node)
            indent = first_line[/\A\s*/] || raise(RubyModKit::Error)
          else
            def_parent_line = generation.line(def_parent_node)
            indent = "  #{def_parent_line[/\A\s*/]}"
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
