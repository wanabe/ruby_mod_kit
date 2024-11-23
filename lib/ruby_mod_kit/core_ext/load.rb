# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit"
require_relative "eval"

# Define RubyMotKit.load/require
module RubyModKit
  module CoreExt
    # the extension for load/require
    module Load
      LOADABLE_EXTS = %w[.rb .rbm .so .o .dll].freeze #: Array[String]

      module_function

      # @rbs path: String
      # @rbs wrap: bool
      # @rbs return: bool
      def load(path, wrap = false) # rubocop:disable Style/OptionalBooleanParameter
        return super unless path.end_with?(".rbm")

        b = wrap ? binding : TOPLEVEL_BINDING
        RubyModKit::CoreExt::Eval.eval(File.read(path), b, path)
        true
      end

      # @rbs path: String
      # @rbs return: bool
      def require(path)
        require_path = Load.require_path(path)
        return super unless require_path&.end_with?(".rbm")
        return false if Load.loaded_features.include?(require_path)

        Load.loaded_features << require_path
        load(require_path)
        true
      end

      class << self
        # @rbs return: Array[String]
        def loaded_features
          $LOADED_FEATURES
        end

        # @rbs return: Array[String]
        def load_path
          $LOAD_PATH
        end

        # @rbs path: String
        # @rbs expanded: bool
        # @rbs return: String | nil
        def require_path(path, expanded: false)
          if !expanded && !File.absolute_path?(path)
            return load_path.each.lazy.map { require_path(File.join(_1, path), expanded: true) }.find(&:itself)
          end

          pathes = if path.end_with?(*LOADABLE_EXTS)
            [path]
          else
            LOADABLE_EXTS.map { "#{path}#{_1}" }
          end
          pathes.find { File.exist?(_1) }
        end
      end
    end
  end

  class << self
    include(CoreExt::Load)
    public :load, :require, :require_relative
  end
end
