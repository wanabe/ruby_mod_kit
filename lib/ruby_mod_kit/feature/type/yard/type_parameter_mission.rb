# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class Yard
        # The mission for parameter types
        class TypeParameterMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            generation.memo_pad.each_parameter_memo do |parameter_memo|
              next if parameter_memo.untyped?

              offset = parameter_memo.offset
              def_node = generation.root_node.def_node_at(offset)
              raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)

              parameter_node = generation.root_node.parameter_node_at(offset)
              raise RubyModKit::Error, "ParameterNode not found" unless parameter_node

              line_offset = generation.line_offset(def_node) || raise(RubyModKit::Error)
              indent = generation.line_indent(def_node)
              script = "#{indent}# @param #{parameter_node.name} [#{Yard.rbs2yard(parameter_memo.type)}]\n"
              generation[line_offset, 0] = script
            end
            true
          end
        end
      end
    end
  end
end
