# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    # namespace for type with rbs-line feature
    class RbsInline < Feature
      # @rbs return: Array[Mission]
      def create_missions
        [
          Feature::RbsInline::TypeInstanceVariableMission.new,
          Feature::RbsInline::TypeAttrMission.new,
          Feature::RbsInline::TypeOverloadMission.new,
          Feature::RbsInline::TypeParameterMission.new,
          Feature::RbsInline::TypeReturnMission.new,
        ]
      end
    end
  end
end

require_relative "rbs_inline/type_attr_mission"
require_relative "rbs_inline/type_instance_variable_mission"
require_relative "rbs_inline/type_overload_mission"
require_relative "rbs_inline/type_parameter_mission"
require_relative "rbs_inline/type_return_mission"
