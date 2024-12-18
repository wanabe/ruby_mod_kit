# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit"

# Define RubyMotKit.eval
module RubyModKit
  # the namespace for language core extensions
  module CoreExt
    # the extension for eval
    module Eval
      module_function

      # @rbs expr: String
      # @rbs binding: Binding
      # @rbs fname: String
      # @rbs lineno: Integer
      # @rbs transpile: bool
      # @rbs return: Object
      # @param expr [String]
      # @param binding [Binding]
      # @param fname [String]
      # @param lineno [Integer]
      # @param transpile [Boolean]
      # @return [Object]
      def eval(expr, binding = TOPLEVEL_BINDING, fname = "(eval)", lineno = 1, transpile: true)
        expr = RubyModKit.transpile(expr, filename: fname) if transpile

        super(expr, binding, fname, lineno)
      end
    end
  end

  class << self
    include(CoreExt::Eval)
    public :eval
  end
end
