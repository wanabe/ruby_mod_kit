# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/mission"

module RubyModKit
  class Mission
    # The mission for parameter types
    class FixParseError < Mission
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs parse_result: Prism::ParseResult
      # @rbs _memo: Memo
      # @rbs return: bool
      def perform(generation, root_node, parse_result, _memo)
        if parse_result.errors.empty?
          generation.add_mission(Mission::Overload.new(0, ""))
          return true
        end

        typed_parameter_offsets = Set.new

        parse_result.errors.each do |parse_error|
          case parse_error.type
          when :argument_formal_ivar
            fix_argument_formal_ivar(parse_error, generation)
          when :unexpected_token_ignore
            if parse_error.location.slice == "=>"
              fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets)
            end
          end
        end

        false
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs return: void
      def fix_argument_formal_ivar(parse_error, generation)
        src_offset = parse_error.location.start_offset

        name = parse_error.location.slice[1..]
        raise RubyModKit::Error unless name

        generation[src_offset, parse_error.location.length] = name
        generation.add_mission(Mission::IvarArg.new(src_offset, "@#{name} = #{name}"))
      end

      # @rbs parse_error: Prism::ParseError
      # @rbs generation: Generation
      # @rbs root_node: Node
      # @rbs typed_parameter_offsets: Set[Integer]
      # @rbs return: void
      def fix_unexpected_assoc(parse_error, generation, root_node, typed_parameter_offsets)
        def_node = root_node[parse_error.location.start_offset, Prism::DefNode]
        return unless def_node

        def_parent_node = def_node.parent
        parameters_node, body_node, = def_node.children
        return if !def_parent_node || !parameters_node || !body_node

        last_parameter_offset = parameters_node.children.map(&:offset).max
        return if typed_parameter_offsets.include?(last_parameter_offset)

        typed_parameter_offsets << last_parameter_offset
        right_node = body_node.children.find do |child_node|
          child_node.offset >= parse_error.location.end_offset
        end
        return unless right_node

        right_offset = right_node.offset
        parameter_type = generation[last_parameter_offset...right_offset]&.sub(/\s*=>\s*\z/, "")
        raise RubyModKit::Error unless parameter_type

        generation[last_parameter_offset, right_offset - last_parameter_offset] = ""
        generation.add_mission(Mission::TypeParameter.new(last_parameter_offset, parameter_type))
      end
    end
  end
end
