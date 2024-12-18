# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    # namespace for overload feature
    class Overload < Feature
      # @rbs return: Array[Mission]
      # @return [Array<Mission>]
      def create_missions
        [
          OverloadMission.new,
        ]
      end
    end
  end
end

require_relative "overload/overload_mission"
