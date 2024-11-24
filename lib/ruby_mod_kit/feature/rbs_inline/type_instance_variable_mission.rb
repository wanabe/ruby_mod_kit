# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Feature
    module RbsInline
      # The mission for instance variable types
      class TypeInstanceVariableMission < Mission
        # @rbs generation: Generation
        # @rbs _root_node: Node::ProgramNode
        # @rbs _parse_result: Prism::ParseResult
        # @rbs memo_pad: MemoPad
        # @rbs return: bool
        def perform(generation, _root_node, _parse_result, memo_pad)
          memo_pad.def_parents_memo.each_value do |def_parent_memo|
            def_parent_memo.ivars_memo.each do |name, ivar_memo|
              offset = ivar_memo.offset || next
              generation[offset, 0] = "#{ivar_memo.indent}# @rbs @#{name}: #{ivar_memo.type}\n"
            end
          end
          true
        end
      end
    end
  end
end
