# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for overload
    class Overload < Mission
      OVERLOAD_METHOD_MAP = {
        "*": "_mul",
      }.freeze #: Hash[Symbol, String]

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        # Wait TypeParameter performed
        @call_count ||= 0
        if @call_count == 0
          @call_count += 1
          return false
        end

        method_memo_groups = memo.methods_memo.each_value.group_by do |method_memo|
          [method_memo.parent_offset, method_memo.name]
        end
        method_memo_groups.each_value do |method_memos|
          next if method_memos.length <= 1

          first_method_memo = method_memos.first
          name = first_method_memo.name
          first_def_node = root_node.def_node_at(first_method_memo.offset)
          raise RubyModKit::Error unless first_def_node.is_a?(Node::DefNode)
          raise RubyModKit::Error unless name.is_a?(Symbol)

          start_line = first_def_node.location.start_line - 1
          indent = parse_result.source.lines[start_line][/\A */] || ""
          start_line -= 1 while parse_result.source.lines[start_line - 1] =~ /^ *# *@rbs /
          src_offset = parse_result.source.offsets[start_line]
          script = +""

          method_memos.each do |method_memo|
            script << if script.empty?
              "# @rbs"
            else
              "#    |"
            end
            script << " (#{method_memo.parameters.map(&:type).join(", ")}) -> #{method_memo.type}\n"
          end
          script << "def #{name}(*args)\n  case args\n"
          overload_prefix = +"#{OVERLOAD_METHOD_MAP[name] || name}_"
          method_memos.each_with_index do |method_memo, i|
            overload_name = "#{overload_prefix}_overload#{i}"
            def_node = root_node.def_node_at(method_memo.offset)
            raise RubyModKit::Error if !def_node || !def_node.is_a?(Node::DefNode)

            name_loc = def_node.name_loc
            generation[name_loc.start_offset, name_loc.length] = overload_name
            script << "  in [#{method_memo.parameters.map(&:type).join(", ")}]\n"
            script << "    #{overload_name}(*args)\n"
          end
          script << "  end\nend\n\n"

          script.gsub!(/^(?=.)/, indent)
          generation[src_offset, 0] = script
        end
        true
      end
    end
  end
end
