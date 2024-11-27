# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit"

# Define RubyMotKit.eval
module RubyModKit
  module CoreExt
    # the extension for eval
    module Eval
      module_function

      # @rbs expr: String
      # @rbs *rest: Object
      # @rbs transpile: bool
      # @rbs return: Object
      def eval(expr, *rest, transpile: true)
        if transpile
          fname = rest[1].is_a?(String) ? rest[1] : "(eval)"
          expr = RubyModKit.transpile(expr, filename: fname)
        end

        case rest
        in []
          super(expr, TOPLEVEL_BINDING)
        in [Binding] | [Binding, String] | [Binding, String, Integer]
          super(expr, *rest)
        end
      end
    end
  end

  class << self
    include(CoreExt::Eval)
    public :eval
  end
end
