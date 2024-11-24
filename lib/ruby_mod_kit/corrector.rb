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
    # @rbs _root_node: Node::ProgramNode
    # @rbs _memo_pad: MemoPad
    # @rbs return: void
    def correct(_parse_error, _generation, _root_node, _memo_pad)
      raise RubyModKit::Error, "Unexpected type #{self.class}"
    end
  end
end
