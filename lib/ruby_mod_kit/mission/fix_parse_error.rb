# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class FixParseError < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs _memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, _memo)
        if parse_result.errors.empty?
          generation.add_mission(Mission::Overload.new(0, ""))
          return true
        end

        typed_parameter_offsets = Set.new

        parse_result.errors.each do |parse_error|
          case parse_error.type
          when :argument_formal_ivar
            fix_argument_formal_ivar(parse_error, generation)
          when :argument_formal_constant
            fix_argument_formal_constant(parse_error, generation, parse_result)
          when :unexpected_token_ignore
            case parse_error.location.slice
            when "=>"
              fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets)
            when ":"
              fix_unexpected_colon(parse_error, generation, root_node)
            end
          end
        end

        false
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs return: void
      def fix_argument_formal_ivar(parse_error, generation)
        src_offset = parse_error.location.start_offset

        name = parse_error.location.slice[1..]
        raise RubyModKit::Error unless name

        generation[src_offset, parse_error.location.length] = name
        generation.add_mission(Mission::IvarArg.new(src_offset, "@#{name} = #{name}"))
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs parse_result: Prism::ParseResult
      # @rbs return: void
      def fix_argument_formal_constant(parse_error, generation, parse_result)
        line = parse_result.source.lines[parse_error.location.start_line - 1]
        line = line[parse_error.location.start_column..]
        return unless line

        parameter_type = line[/(\A[A-Z]\w*(?:::[A-Z]\w*)+)(?:\s*=>\s*)/, 1]
        return unless parameter_type

        src_offset = parse_error.location.start_offset
        generation[src_offset, parameter_type.length] = "(#{parameter_type})"
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs typed_parameter_offsets: Set[Integer]
      # @rbs return: void
      def fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets)
        def_node = root_node[parse_error.location.start_offset, Prism::DefNode]
        return unless def_node

        def_parent_node = def_node.parent
        parameters_node, body_node, = def_node.children
        return if !def_parent_node || !parameters_node || !body_node

        last_parameter_offset = parameters_node.children.map(&:offset).max
        return if typed_parameter_offsets.include?(last_parameter_offset)

        typed_parameter_offsets << last_parameter_offset
        right_node = body_node.children.find do |child_node|
          child_node.offset >= parse_error.location.end_offset
        end
        return unless right_node

        right_offset = right_node.offset
        parameter_type = generation[last_parameter_offset...right_offset]&.sub(/\s*=>\s*\z/, "")
        raise RubyModKit::Error unless parameter_type

        generation[last_parameter_offset, right_offset - last_parameter_offset] = ""
        generation.add_mission(Mission::TypeParameter.new(last_parameter_offset, parameter_type))
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs return: void
      def fix_unexpected_colon(parse_error, generation, root_node)
        def_node = root_node[parse_error.location.start_offset, Prism::DefNode]
        return unless def_node
        return unless def_node.prism_node.is_a?(Prism::DefNode)

        lparen_loc = def_node.prism_node.lparen_loc
        rparen_loc = def_node.prism_node.rparen_loc
        if !lparen_loc && !rparen_loc
          src_offset = def_node.prism_node.name_loc.end_offset
        elsif lparen_loc && rparen_loc && lparen_loc.slice == "(" && rparen_loc.slice == ")"
          src_offset = rparen_loc.end_offset
        else
          return
        end
        return if generation[src_offset...parse_error.location.start_offset] !~ /\A\s*\z/

        return_type_location = root_node[parse_error.location.end_offset + 1]&.prism_node&.location
        return unless return_type_location

        generation[src_offset, return_type_location.end_offset - src_offset] = ""
        generation.add_mission(Mission::TypeReturn.new(src_offset, return_type_location.slice))
      end
    end
  end
end
