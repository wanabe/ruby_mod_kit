# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      module Check
        # The mission to add magic comment
        class AddArgumentsCheckerMission < Mission
          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            # reload if line break is added
            line_break_added = false

            generation.memo_pad.methods_memo.each do |offset, method_memo|
              def_node = generation.root_node.def_node_at(offset)
              raise RubyModKit::Error, "DefNode not found" unless def_node
              next if method_memo.parameters.empty?

              def_line = generation.line(def_node.location.start_line - 1)
              def_indent = def_line[/\A\s*/] || ""

              location = def_node.body_location || def_node.end_keyword_loc
              next unless location

              def_right_loc = def_node.rparen_loc || def_node.name_loc
              offset = location.start_offset - location.start_column
              indent = "#{def_indent}  "
              if location.start_line == def_right_loc.end_line
                between_def_and_loc = generation[def_right_loc.end_offset...location.start_offset]
                length = between_def_and_loc[/\A[ ^t]*;[ ^t]*\z/]&.length
                if length
                  line_break_added = true
                  generation[def_right_loc.end_offset, length] = "\n#{def_indent}"
                end
              end
              next if line_break_added

              method_memo.parameters.each do |parameter_memo|
                next if parameter_memo.untyped? || !parameter_memo.name
                next if parameter_memo.qualifier # TODO: qualifier support

                type = parameter_memo.type
                type = type.gsub(/\[([^\[\]]+)\]/, "") # TODO: type variable support
                generation[offset, 0] = "#{indent}#{parameter_memo.name} => #{type}\n"
              end
            end
            !line_break_added
          end
        end
      end
    end
  end
end
