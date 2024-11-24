# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class RbsInline
      # The mission for parameter types
      class TypeOverloadMission < Mission
        # @rbs generation: Generation
        # @rbs root_node: Node::ProgramNode
        # @rbs parse_result: Prism::ParseResult
        # @rbs memo_pad: MemoPad
        # @rbs return: bool
        def perform(generation, root_node, parse_result, memo_pad)
          memo_pad.overloads_memo.each_value do |overload_memo|
            overload_memo.correct_offset(root_node)
            offset = overload_memo.offset
            def_node = root_node.def_node_at(offset) || raise(RubyModKit::Error)
            start_line = def_node.location.start_line - 1
            indent = parse_result.source.lines[start_line][/\A */] || ""
            offset -= indent.length

            annotation = +""
            overload_memo.overload_types.each do |parameter_types, return_type|
              annotation << if annotation.empty?
                "# @rbs"
              else
                "#    |"
              end
              annotation << " (#{parameter_types.join(", ")}) -> #{return_type}\n"
            end
            annotation.gsub!(/^/, indent)
            generation[offset, 0] = annotation
          end
          true
        end
      end
    end
  end
end
