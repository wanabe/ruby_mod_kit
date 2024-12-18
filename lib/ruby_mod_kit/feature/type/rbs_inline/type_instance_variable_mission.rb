# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for instance variable types
        class TypeInstanceVariableMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            generation.memo_pad.def_parents_memo.each_value do |def_parent_memo|
              def_parent_memo.ivars_memo.each do |name, ivar_memo|
                offset = ivar_memo.offset || next
                def_parent_node = generation.root_node.def_parent_node_at(offset) || next
                body_line_offset = generation.line_offset(def_parent_node, 1) || next
                generation.memo_pad.flags[:rbs_annotated] = true
                script = "#{ivar_memo.indent}# @rbs @#{name}: #{ivar_memo.type}\n#{ivar_memo.separator}"
                generation[body_line_offset, 0] = script
              end
            end
            true
          end
        end
      end
    end
  end
end
