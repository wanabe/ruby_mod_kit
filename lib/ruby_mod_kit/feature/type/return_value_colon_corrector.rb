# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # the class to correct `def foo: Some ...` -> `def foo ...`
      class ReturnValueColonCorrector < Corrector
        # @rbs return: Array[Symbol]
        def correctable_error_types
          %i[unexpected_token_ignore]
        end

        # @rbs parse_error: Prism::ParseError
        # @rbs generation: Generation
        # @rbs _root_node: Node::ProgramNode
        # @rbs _memo_pad: MemoPad
        # @rbs return: void
        def correct(parse_error, generation, _root_node, _memo_pad)
          return if parse_error.location.slice != ":"

          def_node = generation.root_node.statements_node_at(parse_error.location.start_offset)&.parent
          return unless def_node.is_a?(Node::DefNode)

          lparen_loc = def_node.lparen_loc
          rparen_loc = def_node.rparen_loc
          if !lparen_loc && !rparen_loc
            src_offset = def_node.name_loc.end_offset
          elsif lparen_loc && rparen_loc && lparen_loc.slice == "(" && rparen_loc.slice == ")"
            src_offset = rparen_loc.end_offset
          else
            return
          end
          return if generation[src_offset...parse_error.location.start_offset] !~ /\A\s*\z/

          right_node = generation.root_node.node_at(parse_error.location.end_offset + 1)
          return_type_location = right_node&.location || return_type_location
          generation[src_offset, return_type_location.end_offset - src_offset] = ""
          generation.memo_pad.method_memo(def_node).type = return_type_location.slice
        end
      end
    end
  end
end
