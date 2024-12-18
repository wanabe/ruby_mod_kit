# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class InstanceVariableParameter
      # the class to correct `def foo(@bar) ...` -> `def foo(bar) ...`
      class InstanceVariableParameterCorrector < Corrector
        # @rbs return: Array[Symbol]
        # @return [Array<Symbol>]
        def correctable_error_types
          %i[argument_formal_ivar]
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs return: void
        # @param parse_error [Prism::ParseError]
        # @param generation [Generation]
        # @return [void]
        def correct(parse_error, generation)
          src_offset = parse_error.location.start_offset

          name = parse_error.location.slice[1..]
          raise RubyModKit::Error unless name

          parameter_position_node = generation.root_node.node_at(src_offset)
          raise RubyModKit::Error unless parameter_position_node

          generation[src_offset, parse_error.location.length] = name
          parameter_memo = generation.memo_pad.parameter_memo(parameter_position_node)
          parameter_memo.ivar_parameter = true

          return unless parameter_memo.untyped?

          def_parent_node = generation.root_node.def_parent_node_at(parse_error.location.start_offset) || return
          ivar_memo_type = generation.memo_pad.def_parent_memo(def_parent_node).ivar_memo(name.to_sym).type || return
          parameter_memo.type = ivar_memo_type
        end
      end
    end
  end
end
