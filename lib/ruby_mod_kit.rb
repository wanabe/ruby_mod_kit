# frozen_string_literal: true

# rbs_inline: enabled

require "rbconfig"
require "prism"

# The root namespace for ruby_mod_kit.
module RubyModKit
  class Error < StandardError; end
  class SyntaxError < ::SyntaxError; end

  class << self
    # @rbs file: String
    # @rbs *args: String
    # @rbs output: String | nil
    # @rbs return: void
    def execute_file(file, *args, output: nil)
      rb_script = transpile_file(file, output: output)
      if output
        execute_rb_file(output, *args)
      else
        execute_rb(rb_script, *args)
      end
    end

    # @rbs file: String
    # @rbs output: String | IO | nil
    # @rbs return: String
    def transpile_file(file, output: nil)
      rb_script = transpile(File.read(file), filename: file)
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
    # @rbs return: String
    def transpile(src, filename: nil)
      Generation.resolve(src, filename: filename).script
    end

    # @rbs file: String
    # @rbs *args: String
    # @rbs return: void
    def execute_rb_file(file, *args)
      system(RbConfig.ruby, file, *args)
    end

    # @rbs path: String
    # @rbs return: String
    def rb_path(path)
      path.sub(/(?:\.rbm)?$/, ".rb")
    end

    # @rbs rb_script: String
    # @rbs *args: String
    # @rbs return: void
    def execute_rb(rb_script, *args)
      ARGV.replace(args)
      eval(rb_script, TOPLEVEL_BINDING) # rubocop:disable Security/Eval
    end
  end
end

require_relative "ruby_mod_kit/version"
require_relative "ruby_mod_kit/generation"
require_relative "ruby_mod_kit/memo"
require_relative "ruby_mod_kit/memo_pad"
require_relative "ruby_mod_kit/mission"
require_relative "ruby_mod_kit/node"
require_relative "ruby_mod_kit/offset_diff"
