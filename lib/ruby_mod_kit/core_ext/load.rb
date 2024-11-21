# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit"

module RubyModKit
  module CoreExt
    # the extension for load/require
    module Load
      LOADABLE_EXTS = %w[.rb .rbm .so .o .dll].freeze #: Array[String]

      module_function

      # @rbs path: String
      # @rbs wrap: bool
      # @rbs return: void
      def load(path, wrap = false) # rubocop:disable Style/OptionalBooleanParameter
        return super unless path.end_with?(".rbm")

        b = wrap ? binding : TOPLEVEL_BINDING
        eval(RubyModKit.transpile(File.read(path), filename: path), b, path) # rubocop:disable Security/Eval
      end

      # @rbs path: String
      # @rbs return: void
      def require(path)
        require_path = Load.require_path(path)
        return super unless require_path&.end_with?(".rbm")
        return if Load.loaded_features.include?(require_path)

        Load.loaded_features << require_path
        load(require_path)
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
end
