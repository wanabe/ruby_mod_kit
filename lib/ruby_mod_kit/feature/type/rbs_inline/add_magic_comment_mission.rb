# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission to add magic comment
        class AddMagicCommentMission < Mission
          # @rbs return: void
          def initialize
            super
            @reloaded = false
          end

          # @rbs generation: Generation
          # @rbs _root_node: Node::ProgramNode
          # @rbs parse_result: Prism::ParseResult
          # @rbs memo_pad: MemoPad
          # @rbs return: bool
          def perform(generation, _root_node, parse_result, memo_pad)
            return true unless memo_pad.flags[:rbs_annotated]

            unless @reloaded
              @reloaded = true
              return false
            end

            offset = 0
            separated = false
            parse_result.source.lines.each do |line|
              break if line =~ /^# @rbs/
              break if line !~ /^#( rbs_inline: enabled)?|(^$)/
              return true if ::Regexp.last_match(1)

              separated = !::Regexp.last_match(2).nil?

              offset += line.length
            end
            script = +""
            script << "\n" unless separated
            generation[offset, 0] = "# rbs_inline: enabled\n\n"
            true
          end
        end
      end
    end
  end
end