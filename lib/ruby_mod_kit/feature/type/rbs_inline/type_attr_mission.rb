# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for parameter types
        class TypeAttrMission < Mission
          # @rbs generation: Generation
          # @rbs _root_node: Node::ProgramNode
          # @rbs _memo_pad: MemoPad
          # @rbs return: bool
          def perform(generation, _root_node, _memo_pad)
            generation.memo_pad.def_parents_memo.each_value do |def_parent_memo|
              ivars_memo = def_parent_memo.ivars_memo.dup
              def_parent_node = generation.root_node.def_parent_node_at(def_parent_memo.offset)
              raise(RubyModKit::Error) unless def_parent_node

              def_parent_node.body_node&.children&.each do |call_node|
                break if ivars_memo.empty?

                if call_node.is_a?(Node::CallNode) && %i[public private protected].include?(call_node.name)
                  call_node = call_node.children[0]
                  call_node = call_node.children[0] if call_node
                end
                next unless call_node.is_a?(Node::CallNode)
                next unless %i[attr_reader attr_writer attr_accessor].include?(call_node.name)

                argument_nodes = call_node.children[0].children
                next if argument_nodes.size != 1 || !argument_nodes[0].is_a?(Node::SymbolNode)

                name = argument_nodes[0].value || next
                ivar_memo = ivars_memo.delete(name) || next
                line = generation.line(call_node)
                length = line[/\A.*(#{call_node.name}\s+:#{name})(?=\n\z)/, 1]&.length || next
                generation.memo_pad.flags[:rbs_annotated] = true
                generation[call_node.location.start_offset + length, 0] = " #: #{ivar_memo.type}"
              end
            end
            true
          end
        end
      end
    end
  end
end
