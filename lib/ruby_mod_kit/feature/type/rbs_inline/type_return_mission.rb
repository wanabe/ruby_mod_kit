# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for parameter types
        class TypeReturnMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            generation.memo_pad.methods_memo.each do |offset, method_memo|
              def_node = generation.root_node.def_node_at(offset)
              raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)
              next if method_memo.untyped?

              src_offset = generation.line_offset(def_node) || raise(RubyModKit::Error)
              indent = offset - src_offset
              generation.memo_pad.flags[:rbs_annotated] = true
              generation[src_offset, 0] = "#{" " * indent}# @rbs return: #{method_memo.type}\n"
            end
            true
          end
        end
      end
    end
  end
end
