# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler.
  class Transpiler
    # @rbs src: String
    # @rbs filename: String | nil
    # @rbs return: String
    def transpile(src, filename: nil)
      Generation.resolve(src, filename: filename).script
    end
  end
end
