# frozen_string_literal: true

# rbs_inline: enabled

require "rbconfig"
require "prism"

# The root namespace for ruby_mod_kit.
module RubyModKit
  # An internal error because of RubyModKit implementation
  class Error < StandardError; end

  # A SyntaxError of rbm script
  class SyntaxError < ::SyntaxError; end

  class << self
    # @rbs file: String
    # @rbs *args: String
    # @rbs output: String | nil
    # @rbs config: Config | nil
    # @rbs return: void
    # @param file [String]
    # @param args [String]
    # @param output [String, nil]
    # @param config [Config, nil]
    # @return [void]
    def execute_file(file, *args, output: nil, config: nil)
      rb_script = transpile_file(file, output: output, config: config)
      if output
        execute_rb_file(output, *args)
      else
        execute_rb(rb_script, *args)
      end
    end

    # @rbs file: String
    # @rbs output: String | IO | nil
    # @rbs config: Config | nil
    # @rbs return: String
    # @param file [String]
    # @param output [String, IO, nil]
    # @param config [Config, nil]
    # @return [String]
    def transpile_file(file, output: nil, config: nil)
      rb_script = transpile(File.read(file), filename: file, config: config)
      case output
      when IO
        output.write(rb_script)
      when String
        File.write(output, rb_script)
      end
      rb_script
    end

    # @rbs src: String
    # @rbs filename: String | nil
    # @rbs config: Config | nil
    # @rbs return: String
    # @param src [String]
    # @param filename [String, nil]
    # @param config [Config, nil]
    # @return [String]
    def transpile(src, filename: nil, config: nil)
      Generation.resolve(src, filename: filename, config: config).script
    end

    # @rbs file: String
    # @rbs *args: String
    # @rbs return: void
    # @param file [String]
    # @param args [String]
    # @return [void]
    def execute_rb_file(file, *args)
      system(RbConfig.ruby, file, *args)
    end

    # @rbs path: String
    # @rbs return: String
    # @param path [String]
    # @return [String]
    def rb_path(path)
      path.sub(/(?:\.rbm)?$/, ".rb")
    end

    # @rbs rb_script: String
    # @rbs *args: String
    # @rbs return: void
    # @param rb_script [String]
    # @param args [String]
    # @return [void]
    def execute_rb(rb_script, *args)
      ARGV.replace(args)
      eval(rb_script, TOPLEVEL_BINDING) # rubocop:disable Security/Eval
    end

    # @rbs type: String
    # @rbs return: String
    # @param type [String]
    # @return [String]
    def unify_type(type)
      type[/\A\(([^()]*)\)\z/, 1] || type
    end
  end
end

require_relative "ruby_mod_kit/version"

require_relative "ruby_mod_kit/config"
require_relative "ruby_mod_kit/corrector"
require_relative "ruby_mod_kit/corrector_manager"
require_relative "ruby_mod_kit/feature"
require_relative "ruby_mod_kit/generation"
require_relative "ruby_mod_kit/memo"
require_relative "ruby_mod_kit/memo_pad"
require_relative "ruby_mod_kit/mission"
require_relative "ruby_mod_kit/node"
require_relative "ruby_mod_kit/offset_diff"
