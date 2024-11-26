# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for parameter types
        class TypeReturnMission < Mission
          # @rbs generation: Generation
          # @rbs root_node: Node::ProgramNode
          # @rbs _parse_result: Prism::ParseResult
          # @rbs memo_pad: MemoPad
          # @rbs return: bool
          def perform(generation, root_node, _parse_result, memo_pad)
            memo_pad.methods_memo.each do |offset, method_memo|
              def_node = root_node.def_node_at(offset)
              raise RubyModKit::Error, "DefNode not found" if !def_node || !def_node.is_a?(Node::DefNode)
              next if method_memo.untyped?

              src_offset = generation.offsets[def_node.location.start_line - 1]
              indent = offset - src_offset
              memo_pad.flags[:rbs_annotated] = true
              generation[src_offset, 0] = "#{" " * indent}# @rbs return: #{method_memo.type}\n"
            end
            true
          end
        end
      end
    end
  end
end
