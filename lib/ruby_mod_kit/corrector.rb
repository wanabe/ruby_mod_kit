# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # the base class of corrector
  class Corrector
    # @rbs return: Array[Symbol]
    def correctable_error_types
      []
    end

    # @rbs _parse_error: Prism::ParseError
    # @rbs _generation: Generation
    # @rbs return: void
    def correct(_parse_error, _generation)
      raise RubyModKit::Error, "Unexpected type #{self.class}"
    end

    # @rbs return: void
    def setup; end
  end
end
