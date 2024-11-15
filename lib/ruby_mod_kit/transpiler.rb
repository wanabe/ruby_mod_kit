# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler.
  class Transpiler
    # @rbs src: String
    # @rbs return: String
    def transpile(src)
      generation = Generation.new(src.dup)
      until generation.completed?
        generation.resolve
        generation = generation.succ
      end
      generation.script
    end
  end
end
