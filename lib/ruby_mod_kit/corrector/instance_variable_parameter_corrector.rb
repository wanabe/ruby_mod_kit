# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Corrector
    # the class to correct `def foo(@bar) ...` -> `def foo(bar) ...`
    class InstanceVariableParameterCorrector
      # @rbs return: Array[Symbol]
      def correctable_error_types
        %i[argument_formal_ivar]
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node::ProgramNode
      # @rbs memo_pad: MemoPad
      # @rbs return: void
      def correct(parse_error, generation, root_node, memo_pad)
        src_offset = parse_error.location.start_offset

        name = parse_error.location.slice[1..]
        raise RubyModKit::Error unless name

        parameter_position_node = root_node.node_at(src_offset)
        raise RubyModKit::Error unless parameter_position_node

        generation[src_offset, parse_error.location.length] = name
        parameter_memo = memo_pad.parameter_memo(parameter_position_node)
        parameter_memo.ivar_parameter = true
        generation.add_mission(Mission::InstanceVariableParameterMission.new(src_offset))

        return unless parameter_memo.untyped?

        def_parent_node = root_node.def_parent_node_at(parse_error.location.start_offset) || return
        ivar_memo_type = memo_pad.def_parent_memo(def_parent_node).ivar_memo(name.to_sym).type || return
        parameter_memo.type = ivar_memo_type
      end
    end
  end
end
