# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"

module RubyModKit
  class Mission
    # The mission for parameter types
    class FixParseError < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        return true if parse_result.errors.empty?

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

            if generation.first_generation?
              overload_id = [def_parent_node.prism_node.location.start_offset, def_node.named_node!.name]
              memo.overload_methods[overload_id] ||= {}
              if memo.overload_methods[overload_id][def_node]
                memo.overload_methods[overload_id][def_node] << parameter_type
              else
                memo.overload_methods[overload_id][def_node] = [parameter_type]
              end
            end

            generation[last_parameter_offset, right_offset - last_parameter_offset] = ""
            generation.add_mission(Mission::TypeParameter.new(last_parameter_offset, parameter_type))
          end
        end

        false
      end
    end
  end
end
