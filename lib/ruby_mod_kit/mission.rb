# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler mission.
  class Mission
    attr_accessor :offset #: Integer
    attr_reader :modify_script #: String

    # @rbs offset: Integer
    # @rbs modify_script: String
    # @rbs return: void
    def initialize(offset, modify_script)
      @offset = offset
      @modify_script = modify_script
    end
  end
end
