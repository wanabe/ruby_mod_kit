# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # namespace for type with rbs-line feature
      class Yard < Feature
        # @rbs return: Array[Mission]
        def create_missions
          [
            TypeParameterMission.new,
            TypeReturnMission.new,
          ]
        end

        class << self
          # @rbs type: String
          # @rbs return: String
          def rbs2yard(type)
            type.gsub(/\s*\|\s*/, ", ").tr("[]", "<>").gsub(/(?<=^|\W)bool(?=$|\W)/, "Boolean")
          end
        end
      end
    end
  end
end

require_relative "yard/type_parameter_mission"
require_relative "yard/type_return_mission"
