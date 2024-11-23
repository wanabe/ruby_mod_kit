# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Corrector
    # the class to correct all. TODO: split class by feature
    class AllCorrector
      # @rbs return: Array[Symbol]
      def correctable_error_types
        %i[unexpected_token_ignore]
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node::ProgramNode
      # @rbs memo_pad: MemoPad
      # @rbs return: void
      def correct(parse_error, generation, root_node, memo_pad)
        return if parse_error.location.slice != ":"

        parent_node = root_node.statements_node_at(parse_error.location.start_offset)&.parent
        case parent_node
        when Node::DefNode
          fix_unexpected_colon_in_def(parse_error, generation, root_node, parent_node, memo_pad)
        when Node::DefParentNode
          fix_unexpected_colon_in_module(parse_error, generation, parent_node, memo_pad)
        end
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node::ProgramNode
      # @rbs def_node: Node::DefNode
      # @rbs memo_pad: MemoPad
      # @rbs return: void
      def fix_unexpected_colon_in_def(parse_error, generation, root_node, def_node, memo_pad)
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

        return_type_location = root_node.node_at(parse_error.location.end_offset + 1)&.location || return_type_location
        generation[src_offset, return_type_location.end_offset - src_offset] = ""
        memo_pad.method_memo(def_node).type = return_type_location.slice
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs def_parent_node: Node::DefParentNode
      # @rbs memo_pad: MemoPad
      # @rbs return: void
      def fix_unexpected_colon_in_module(parse_error, generation, def_parent_node, memo_pad)
        line = generation.line(parse_error)
        line_offset = generation.src_offset(parse_error) || return
        attr_patterns = %i[attr_reader reader getter attr_writer writer setter attr_accessor accessor property]
        return if line !~ /(\A\s*)(?:(#{attr_patterns.join("|")}) )?@(\w*)\s*:\s*(.*)/

        length = ::Regexp.last_match(0)&.length
        indent = ::Regexp.last_match(1)
        attr_kind = ::Regexp.last_match(2)
        ivar_name = ::Regexp.last_match(3)
        type = ::Regexp.last_match(4)
        return if !length || !indent || !ivar_name || !type

        ivar_memo = memo_pad.def_parent_memo(def_parent_node).ivar_memo(ivar_name.to_sym)
        ivar_memo.type = type
        ivar_memo.attr_kind = attr_kind if attr_kind

        generation[line_offset, length] = "#{indent}# @rbs @#{ivar_name}: #{RubyModKit.unify_type(type)}"
      end
    end
  end
end
