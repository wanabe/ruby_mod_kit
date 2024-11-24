# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # namespace for type with rbs-line feature
      class RbsInline < Feature
        # @rbs return: Array[Mission]
        def create_missions
          [
            TypeInstanceVariableMission.new,
            TypeAttrMission.new,
            TypeOverloadMission.new,
            TypeParameterMission.new,
            TypeReturnMission.new,
            # This mission must be the last
            AddMagicCommentMission.new,
          ]
        end
      end
    end
  end
end

require_relative "rbs_inline/add_magic_comment_mission"
require_relative "rbs_inline/type_attr_mission"
require_relative "rbs_inline/type_instance_variable_mission"
require_relative "rbs_inline/type_overload_mission"
require_relative "rbs_inline/type_parameter_mission"
require_relative "rbs_inline/type_return_mission"
