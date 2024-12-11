# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The base class of transpiler mission.
  class Mission
    # @rbs _generation: Generation
    # @rbs return: void
    # @param _generation [Generation]
    # @return [void]
    def perform(_generation)
      raise RubyModKit::Error, "Unexpected type #{self.class}"
    end
  end
end
