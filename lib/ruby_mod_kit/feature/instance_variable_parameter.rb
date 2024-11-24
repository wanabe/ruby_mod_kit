# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    # namespace for instance_variable parameter feature
    class InstanceVariableParameter < Feature
      # @rbs return: Array[Corrector]
      def create_correctors
        [
          InstanceVariableParameterCorrector.new,
        ]
      end

      # @rbs return: Array[Mission]
      def create_missions
        [
          InstanceVariableParameterMission.new,
        ]
      end
    end
  end
end

require_relative "instance_variable_parameter/instance_variable_parameter_corrector"
require_relative "instance_variable_parameter/instance_variable_parameter_mission"
