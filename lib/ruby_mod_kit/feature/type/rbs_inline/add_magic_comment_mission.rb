# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      class RbsInline
        # The mission to add magic comment
        class AddMagicCommentMission < Mission
          # @rbs @reloaded: bool

          # @rbs return: void
          # @return [void]
          def initialize
            super
            @reloaded = false
          end

          # @rbs generation: Generation
          # @rbs return: bool
          # @param generation [Generation]
          # @return [Boolean]
          def perform(generation)
            return true unless generation.memo_pad.flags[:rbs_annotated]

            unless @reloaded
              @reloaded = true
              return false
            end

            offset = 0
            separated = false
            generation.lines.each do |line|
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
