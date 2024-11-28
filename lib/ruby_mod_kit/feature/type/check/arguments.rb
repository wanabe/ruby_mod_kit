# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      module Check
        # namespace for arguments type checker
        class Arguments < Feature
          # @rbs return: Array[Mission]
          def create_missions
            [
              AddArgumentsCheckerMission.new,
            ]
          end
        end
      end
    end
  end
end

require_relative "arguments/add_arguments_checker_mission"
