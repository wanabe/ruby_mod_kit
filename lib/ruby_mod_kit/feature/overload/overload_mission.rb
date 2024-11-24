# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Overload
      # The mission for overload
      class OverloadMission < Mission
        OVERLOAD_METHOD_MAP = {
          "*": "_mul",
        }.freeze #: Hash[Symbol, String]

        # @rbs @modified: bool

        # @rbs return: void
        def initialize
          super
          @modified = false
        end

        # @rbs generation: Generation
        # @rbs root_node: Node::ProgramNode
        # @rbs parse_result: Prism::ParseResult
        # @rbs memo_pad: MemoPad
        # @rbs return: bool
        def perform(generation, root_node, parse_result, memo_pad)
          return true if @modified

          method_memo_groups = memo_pad.methods_memo.each_value.group_by do |method_memo|
            [root_node.def_parent_node_at(method_memo.offset), method_memo.name]
          end
          method_memo_groups.each_value do |method_memos|
            next if method_memos.length <= 1

            @modified = true
            first_method_memo = method_memos.first
            name = first_method_memo.name
            first_def_node = root_node.def_node_at(first_method_memo.offset)
            raise RubyModKit::Error unless first_def_node.is_a?(Node::DefNode)
            raise RubyModKit::Error unless name.is_a?(Symbol)

            start_line = first_def_node.location.start_line - 1
            indent = parse_result.source.lines[start_line][/\A */] || ""
            src_offset = parse_result.source.offsets[start_line]
            script = +""

            overload_memo = memo_pad.overload_memo(first_method_memo.offset, name)

            method_memos.each do |method_memo|
              type = method_memo.type
              type = "(#{type})" if type.include?(" ")
              overload_memo.add_overload_type(method_memo.parameters.map(&:type), type)
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

          # if script has been changed, request reparsing before proceeding to the next mission
          !@modified
        end
      end
    end
  end
end