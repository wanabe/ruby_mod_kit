# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit/context"

module RubyModKit
  # The class of transpiler.
  class Transpiler
    # @rbs src: String
    # @rbs return: void
    def initialize(src)
      @src = src
    end

    # @rbs return: String
    def transpile
      Context.new(@src).transpile
    end
  end
end
