# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    # namespace for type feature
    class Type < Feature
      # @rbs return: Array[Corrector]
      def create_correctors
        [
          InstanceVariableColonCorrector.new,
          ParameterArrowCorrector.new,
          ReturnValueColonCorrector.new,
        ]
      end
    end
  end
end

require_relative "type/instance_variable_colon_corrector"
require_relative "type/parameter_arrow_corrector"
require_relative "type/return_value_colon_corrector"
