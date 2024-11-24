# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Feature
    # namespace for type with rbs-line feature
    module RbsInline
    end
  end
end

require_relative "rbs_inline/type_attr_mission"
require_relative "rbs_inline/type_instance_variable_mission"
require_relative "rbs_inline/type_overload_mission"
require_relative "rbs_inline/type_parameter_mission"
require_relative "rbs_inline/type_return_mission"
