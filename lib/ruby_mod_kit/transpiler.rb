# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler.
  class Transpiler
    # @rbs src: String
    # @rbs filename: String | nil
    # @rbs return: String
    def transpile(src, filename: nil)
      generation = Generation.new(src.dup, filename: filename)
      until generation.completed?
        generation.resolve
        generation = generation.succ
      end
      generation.script
    end
  end
end
