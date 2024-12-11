# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission for parameter types
        class TypeOverloadMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            generation.memo_pad.overloads_memo.each_value do |overload_memo|
              overload_memo.correct_offset(generation.root_node)
              offset = overload_memo.offset
              def_node = generation.root_node.def_node_at(offset) || raise(RubyModKit::Error)
              indent = generation.line_indent(def_node)
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
              generation.memo_pad.flags[:rbs_annotated] = true
              generation[offset, 0] = annotation
            end
            true
          end
        end
      end
    end
  end
end
