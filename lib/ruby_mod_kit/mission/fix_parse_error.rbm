# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"

module RubyModKit
  class Mission
    # The mission for parameter types
    class FixParseError < Mission
      OVERLOAD_METHOD_MAP = {
        "*": "_mul",
      }.freeze #: Hash[Symbol, String]

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      def perform(generation, root_node, parse_result)
        overload_methods = {} if generation.first_generation?
        typed_parameter_offsets = Set.new

        parse_result.errors.each do |parse_error|
          case parse_error.type
          when :argument_formal_ivar
            src_offset = parse_error.location.start_offset

            name = parse_error.location.slice[1..]
            if parse_error.location.slice[0] != "@" || !name
              raise RubyModKit::Error,
                    "Expected ivar but '#{parse_error.location.slice}'"
            end

            generation[src_offset, parse_error.location.length] = name
            generation.add_mission(Mission::IvarArg.new(src_offset, "@#{name} = #{name}"))
          when :unexpected_token_ignore
            next if parse_error.location.slice != "=>"

            def_node = root_node[parse_error.location.start_offset, Prism::DefNode]
            next unless def_node

            def_parent_node = def_node.parent
            parameters_node, body_node, = def_node.children
            next if !def_parent_node || !parameters_node || !body_node

            last_parameter_offset = parameters_node.children.map { _1.prism_node.location.start_offset }.max
            next if typed_parameter_offsets.include?(last_parameter_offset)

            typed_parameter_offsets << last_parameter_offset
            right_node = body_node.children.find do |child_node|
              child_node.prism_node.location.start_offset >= parse_error.location.end_offset
            end
            next unless right_node

            right_offset = right_node.prism_node.location.start_offset
            parameter_type = generation[last_parameter_offset...right_offset]&.sub(/\s*=>\s*\z/, "")
            raise RubyModKit::Error unless parameter_type

            if overload_methods
              overload_id = [def_parent_node.prism_node.location.start_offset, def_node.named_node!.name]
              overload_methods[overload_id] ||= {}
              overload_methods[overload_id][def_node] ||= []
              overload_methods[overload_id][def_node] << parameter_type
            end

            generation[last_parameter_offset, right_offset - last_parameter_offset] = ""
            generation.add_mission(Mission::TypeParameter.new(last_parameter_offset, parameter_type))
          end
        end

        overload_methods&.each do |(_, name), def_node_part_pairs|
          next if def_node_part_pairs.size <= 1

          first_def_node = def_node_part_pairs.first[0]
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
      end
    end
  end
end
