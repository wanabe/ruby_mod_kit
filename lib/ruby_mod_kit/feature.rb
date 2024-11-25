# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # the base class of feature
  class Feature
    # @rbs return: Array[Corrector]
    def create_correctors
      []
    end

    # @rbs return: Array[Mission]
    def create_missions
      []
    end
  end
end
