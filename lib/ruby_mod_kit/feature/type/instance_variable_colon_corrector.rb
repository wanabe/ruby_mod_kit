# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # the class to correct `@var: Type` -> `# @rbs @var: Type`
      class InstanceVariableColonCorrector < Corrector
        VISIBILITIES = %i[private public protected].freeze #: Array[Symbol]
        ATTR_PATTERNS = %i[attr_reader reader getter attr_writer writer setter attr_accessor accessor property].freeze #: Array[Symbol]
        REGEXP = /(\A\s*)(?:(#{VISIBILITIES.join("|")}) )?(?:(#{ATTR_PATTERNS.join("|")}) )?@(\w*)\s*:\s*(.*)\n/.freeze #: Regexp

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

          def_parent_node = generation.root_node.statements_node_at(parse_error.location.start_offset)&.parent
          return unless def_parent_node.is_a?(Node::DefParentNode)

          line = generation.line(parse_error)
          line_offset = generation.src_offset(parse_error) || return
          return if line !~ REGEXP

          length = ::Regexp.last_match(0)&.length
          indent = ::Regexp.last_match(1)
          visibility = ::Regexp.last_match(2)
          attr_kind = ::Regexp.last_match(3)
          ivar_name = ::Regexp.last_match(4)
          type = ::Regexp.last_match(5)
          return if !length || !indent || !ivar_name || !type

          ivar_memo = generation.memo_pad.def_parent_memo(def_parent_node).ivar_memo(ivar_name.to_sym)
          ivar_memo.type = type
          ivar_memo.offset = line_offset
          ivar_memo.indent = indent
          ivar_memo.attr_kind = attr_kind if attr_kind
          ivar_memo.visibility = visibility.to_sym if visibility

          generation[line_offset, length] = ""
        end
      end
    end
  end
end
