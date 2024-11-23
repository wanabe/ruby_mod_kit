# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Mission
    # The mission for parameter types
    class FixParseErrorMission < Mission::BaseMission
      # @rbs @previous_error_messages: Array[String]

      # @rbs return: void
      def initialize
        super(0)
        @previous_error_messages = []
      end

      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, memo)
        return true if parse_result.errors.empty?

        check_prev_errors(generation, parse_result)
        @previous_error_messages = parse_result.errors.map(&:message)

        parse_result.errors.each do |parse_error|
          case parse_error.type
          when :argument_formal_ivar
            fix_argument_formal_ivar(parse_error, generation, root_node, memo)
          when :argument_formal_constant
            fix_argument_formal_constant(parse_error, generation)
          when :unexpected_token_ignore
            case parse_error.location.slice
            when "=>"
              fix_unexpected_assoc(parse_error, generation, root_node, memo)
            when ":"
              fix_unexpected_colon(parse_error, generation, root_node, memo)
            end
          when :def_params_term_paren
            fix_def_params_term_paren(parse_error, generation, root_node, memo)
          end
        end

        false
      end

      # @rbs generation: Generation
      # @rbs parse_result: Prism::ParseResult
      # @rbs return: void
      def check_prev_errors(generation, parse_result)
        return if @previous_error_messages.empty?
        return if parse_result.errors.empty?
        return if @previous_error_messages != parse_result.errors.map(&:message)

        message = +""
        parse_result.errors.each do |parse_error|
          message << "\n" unless message.empty?
          message << "#{generation.name}:#{parse_error.location.start_line}:#{parse_error.message} "
          message << "(#{parse_error.type})"
          line = parse_result.source.lines[parse_error.location.start_line - 1]
          if line
            message << "\n#{line.chomp}\n"
            message << "#{" " * parse_error.location.start_column}^#{"~" * [parse_error.location.length - 1, 0].max}"
          end
        end
        raise RubyModKit::SyntaxError, message
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs memo: Memo
      # @rbs return: void
      def fix_def_params_term_paren(parse_error, generation, root_node, memo)
        column = parse_error.location.start_column - 1
        return if column < 0

        line = generation.line(parse_error)[column..] || return
        line =~ /\A\*(.*?)\s*=>\s*/
        length = ::Regexp.last_match(0)&.length || return
        type = ::Regexp.last_match(1) || return
        offset = parse_error.location.start_offset - 1
        parameter_position_node = root_node.node_at(offset + length) || return

        generation[parse_error.location.start_offset, length - 1] = ""
        parameter_memo = memo.parameter_memo(parameter_position_node)
        parameter_memo.type = type
        parameter_memo.qualifier = "*"
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs memo: Memo
      # @rbs return: void
      def fix_argument_formal_ivar(parse_error, generation, root_node, memo)
        src_offset = parse_error.location.start_offset

        name = parse_error.location.slice[1..]
        raise RubyModKit::Error unless name

        parameter_position_node = root_node.node_at(src_offset)
        raise RubyModKit::Error unless parameter_position_node

        generation[src_offset, parse_error.location.length] = name
        parameter_memo = memo.parameter_memo(parameter_position_node)
        parameter_memo.ivar_parameter = true
        generation.add_mission(Mission::InstanceVariableParameterMission.new(src_offset))

        return unless parameter_memo.untyped?

        def_parent_node = root_node.def_parent_node_at(parse_error.location.start_offset) || return
        ivar_memo_type = memo.def_parent_memo(def_parent_node).ivar_memo(name.to_sym).type || return
        parameter_memo.type = ivar_memo_type
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs return: void
      def fix_argument_formal_constant(parse_error, generation)
        line = generation.line(parse_error)
        line = line[parse_error.location.start_column..] || return
        parameter_type = line[/(\A[A-Z]\w*(?:::[A-Z]\w*)+)(?:\s*=>\s*)/, 1] || return
        src_offset = parse_error.location.start_offset
        generation[src_offset, parameter_type.length] = "(#{parameter_type})"
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_assoc(parse_error, generation, root_node, memo)
        def_node = root_node.def_node_at(parse_error.location.start_offset) || return
        def_parent_node = def_node.parent
        parameters_node, body_node, = def_node.children
        return if !def_parent_node || !parameters_node || !body_node

        last_parameter_node = parameters_node.children.max_by(&:offset) || return
        last_parameter_offset = last_parameter_node.offset

        right_node = body_node.children.find { _1.offset >= parse_error.location.end_offset } || return
        right_offset = right_node.offset
        parameter_type = generation[last_parameter_offset...right_offset] || raise(RubyModKit::Error)
        parameter_type = parameter_type.sub(/\s*=>\s*\z/, "")
        generation[last_parameter_offset, right_offset - last_parameter_offset] = ""
        memo.parameter_memo(last_parameter_node).type = parameter_type
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_colon(parse_error, generation, root_node, memo)
        parent_node = root_node.statements_node_at(parse_error.location.start_offset)&.parent
        case parent_node
        when Node::DefNode
          fix_unexpected_colon_in_def(parse_error, generation, root_node, parent_node, memo)
        when Node::DefParentNode
          fix_unexpected_colon_in_module(parse_error, generation, parent_node, memo)
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

        return_type_location = root_node.node_at(parse_error.location.end_offset + 1)&.location || return_type_location
        generation[src_offset, return_type_location.end_offset - src_offset] = ""
        memo.method_memo(def_node).type = return_type_location.slice
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs def_parent_node: Node::DefParentNode
      # @rbs memo: Memo
      # @rbs return: void
      def fix_unexpected_colon_in_module(parse_error, generation, def_parent_node, memo)
        line = generation.line(parse_error)
        line_offset = generation.src_offset(parse_error) || return
        attr_patterns = %i[attr_reader reader getter attr_writer writer setter attr_accessor accessor property]
        return if line !~ /(\A\s*)(?:(#{attr_patterns.join("|")}) )?@(\w*)\s*:\s*(.*)/

        length = ::Regexp.last_match(0)&.length
        indent = ::Regexp.last_match(1)
        attr_kind = ::Regexp.last_match(2)
        ivar_name = ::Regexp.last_match(3)
        type = ::Regexp.last_match(4)
        return if !length || !indent || !ivar_name || !type

        ivar_memo = memo.def_parent_memo(def_parent_node).ivar_memo(ivar_name.to_sym)
        ivar_memo.type = type
        ivar_memo.attr_kind = attr_kind if attr_kind

        generation[line_offset, length] = "#{indent}# @rbs @#{ivar_name}: #{Memo.unify_type(type)}"
      end
    end
  end
end
