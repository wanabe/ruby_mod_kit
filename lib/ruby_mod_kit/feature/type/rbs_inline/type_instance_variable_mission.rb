# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for instance variable types
        class TypeInstanceVariableMission < Mission
          # @rbs generation: Generation
          # @rbs root_node: Node::ProgramNode
          # @rbs _parse_result: Prism::ParseResult
          # @rbs memo_pad: MemoPad
          # @rbs return: bool
          def perform(generation, root_node, _parse_result, memo_pad)
            memo_pad.def_parents_memo.each_value do |def_parent_memo|
              def_parent_memo.ivars_memo.each do |name, ivar_memo|
                offset = ivar_memo.offset || next
                def_parent_node = root_node.def_parent_node_at(offset) || next
                body_line_offset = generation.offsets[def_parent_node.location.start_line]
                memo_pad.flags[:rbs_annotated] = true
                generation[body_line_offset, 0] = "#{ivar_memo.indent}# @rbs @#{name}: #{ivar_memo.type}\n"
              end
            end
            true
          end
        end
      end
    end
  end
end
