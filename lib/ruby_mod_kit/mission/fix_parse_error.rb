# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Mission
    # The mission for parameter types
    class FixParseError < Mission
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
        if parse_result.errors.empty?
          generation.add_mission(Mission::Overload.new)
          generation.add_mission(Mission::TypeParameter.new)
          generation.add_mission(Mission::TypeReturn.new)
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
              fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets, memo)
            when ":"
              fix_unexpected_colon(parse_error, generation, root_node, parse_result, memo)
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
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets, memo)
        def_node = root_node.def_node_at(parse_error.location.start_offset)
        return unless def_node

        def_parent_node = def_node.parent
        parameters_node, body_node, = def_node.children
        return if !def_parent_node || !parameters_node || !body_node

        last_parameter_node = parameters_node.children.max_by(&:offset)
        return unless last_parameter_node

        last_parameter_offset = last_parameter_node.offset
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
        memo.parameter_memo(last_parameter_node).type = parameter_type
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_colon(parse_error, generation, root_node, parse_result, memo)
        parent_node = root_node.statements_node_at(parse_error.location.start_offset)&.parent
        case parent_node
        when Node::DefNode
          fix_unexpected_colon_in_def(parse_error, generation, root_node, parent_node, memo)
        when Node::ClassNode
          fix_unexpected_colon_in_module(parse_error, generation, parse_result)
        end
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs def_node: Node::DefNode
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_colon_in_def(parse_error, generation, root_node, def_node, memo)
        lparen_loc = def_node.lparen_loc
        rparen_loc = def_node.rparen_loc
        if !lparen_loc && !rparen_loc
          src_offset = def_node.name_loc.end_offset
        elsif lparen_loc && rparen_loc && lparen_loc.slice == "(" && rparen_loc.slice == ")"
          src_offset = rparen_loc.end_offset
        else
          return
        end
        return if generation[src_offset...parse_error.location.start_offset] !~ /\A\s*\z/

        return_type_location = root_node.node_at(parse_error.location.end_offset + 1)&.location
        return unless return_type_location

        generation[src_offset, return_type_location.end_offset - src_offset] = ""
        memo.method_memo(def_node).type = return_type_location.slice
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs parse_result: Prism::ParseResult
      # @rbs return: void
      def fix_unexpected_colon_in_module(parse_error, generation, parse_result)
        line = parse_result.source.lines[parse_error.location.start_line - 1]
        line_offset = parse_result.source.offsets[parse_error.location.start_line - 1]
        return if line !~ /(\A\s*)@(\w*)\s*:\s*(.*)/

        indent = ::Regexp.last_match(1)
        ivar_name = ::Regexp.last_match(2)
        type = ::Regexp.last_match(3)
        return if !indent || !ivar_name || !type

        generation[line_offset + indent.length, 0] = "# @rbs "
      end
    end
  end
end
