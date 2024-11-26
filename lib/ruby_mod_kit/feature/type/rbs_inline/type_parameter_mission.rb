# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for parameter types
        class TypeParameterMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          def perform(generation)
            generation.memo_pad.parameters_memo.each do |offset, parameter_memo|
              next if parameter_memo.untyped?

              def_node = generation.root_node.def_node_at(offset)
              raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)

              parameter_node = generation.root_node.parameter_node_at(offset)
              raise RubyModKit::Error, "ParameterNode not found" unless parameter_node

              type = parameter_memo.type
              src_offset = generation.offsets[def_node.location.start_line - 1]
              indent = def_node.offset - src_offset
              qualified_name = "#{parameter_memo.qualifier}#{parameter_node.name}"
              generation.memo_pad.flags[:rbs_annotated] = true
              generation[src_offset, 0] = "#{" " * indent}# @rbs #{qualified_name}: #{type}\n"
            end
            true
          end
        end
      end
    end
  end
end
