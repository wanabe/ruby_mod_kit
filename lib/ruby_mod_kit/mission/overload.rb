# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"

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
      def perform(generation, _root_node, parse_result, memo)
        memo.overload_methods.each do |(_, name), def_node_part_pairs|
          next if def_node_part_pairs.size <= 1
          raise RubyModKit::Error unless name.is_a?(Symbol)

          first_def_node_part_pairs = def_node_part_pairs.first
          raise RubyModKit::Error unless first_def_node_part_pairs

          first_def_node = first_def_node_part_pairs[0]
          src_offset = parse_result.source.offsets[first_def_node.prism_node.location.start_line - 1]
          script = +""
          def_node_part_pairs.each_value do |parts|
            script << if script.empty?
              "# @rbs"
            else
              "#    |"
            end
            script << " (#{parts.join(", ")}) -> untyped\n"
          end

          script << "def #{name}(*args)\n  case args\n"
          overload_prefix = +"#{OVERLOAD_METHOD_MAP[name] || name}_"
          def_node_part_pairs.each_with_index do |(def_node, parts), i|
            overload_name = "#{overload_prefix}_overload#{i}"
            raise RubyModKit::Error unless def_node.prism_node.is_a?(Prism::DefNode)

            name_loc = def_node.prism_node.name_loc
            generation[name_loc.start_offset, name_loc.length] = overload_name
            script << "  in [#{parts.join(", ")}]\n"
            script << "    #{overload_name}(*args)\n"
          end
          script << "  end\nend\n\n"
          indent = first_def_node.prism_node.location.start_offset - src_offset
          script.gsub!(/^(?=.)/, " " * indent)
          generation[src_offset, 0] = script
        end
        true
      end
    end
  end
end
