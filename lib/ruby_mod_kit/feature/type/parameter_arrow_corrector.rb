# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # the class to correct `def foo(Bar => bar, *Buz => buz)` -> `def foo(bar, *buz)`
      class ParameterArrowCorrector < Corrector
        # @rbs return: Array[Symbol]
        def correctable_error_types
          %i[unexpected_token_ignore def_params_term_paren argument_formal_constant]
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs return: void
        def correct(parse_error, generation)
          case parse_error.type
          when :unexpected_token_ignore
            return if parse_error.location.slice != "=>"

            remove_arrow_before_parameter(parse_error, generation)
          when :def_params_term_paren
            remove_arrow_after_quailifier(parse_error, generation)
          when :argument_formal_constant
            wrap_parameter_type_for_next_parse(parse_error, generation)
          end
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs return: void
        def remove_arrow_before_parameter(parse_error, generation)
          def_node = generation.root_node.def_node_at(parse_error.location.start_offset) || return
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
          generation.memo_pad.parameter_memo(last_parameter_node).type = parameter_type
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs return: void
        def remove_arrow_after_quailifier(parse_error, generation)
          column = parse_error.location.start_column - 1
          return if column < 0

          line = generation.line(parse_error)[column..] || return
          line =~ /\A\*(.*?)\s*=>\s*/
          length = ::Regexp.last_match(0)&.length || return
          type = ::Regexp.last_match(1) || return
          offset = parse_error.location.start_offset - 1
          parameter_position_node = generation.root_node.node_at(offset + length) || return

          generation[parse_error.location.start_offset, length - 1] = ""
          parameter_memo = generation.memo_pad.parameter_memo(parameter_position_node)
          parameter_memo.type = type
          parameter_memo.qualifier = "*"
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs return: void
        def wrap_parameter_type_for_next_parse(parse_error, generation)
          line = generation.line(parse_error)
          line = line[parse_error.location.start_column..] || return
          parameter_type = line[/(\A[A-Z]\w*(?:::[A-Z]\w*)+)(?:\s*=>\s*)/, 1] || return
          src_offset = parse_error.location.start_offset
          generation[src_offset, parameter_type.length] = "(#{parameter_type})"
        end
      end
    end
  end
end
