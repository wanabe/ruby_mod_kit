# frozen_string_literal: true

# rbs_inline: enabled

require "rbconfig"
require "prism"

# The root namespace for ruby_mod_kit.
module RubyModKit
  class Error < StandardError; end

  class << self
    # @rbs *args: String
    # @rbs file: String
    # @rbs return: void
    def execute_file(file, *args)
      rb_file = transpile_file(file)
      execute_rb_file(rb_file, *args)
    end

    # @rbs file: String
    # @rbs return: String
    def transpile_file(file)
      rb_src = transpile(File.read(file))
      rb_path = rb_path(file)
      File.write(rb_path, rb_src)
      rb_path
    end

    # @rbs src: String
    # @rbs return: String
    def transpile(src)
      Transpiler.new.transpile(src)
    end

    # @rbs *args: String
    # @rbs file: String
    # @rbs return: void
    def execute_rb_file(file, *args)
      system(RbConfig.ruby, file, *args)
    end

    # @rbs path: String
    # @rbs return: String
    def rb_path(path)
      path.sub(/(?:\.rbm)?$/, ".rb")
    end
  end
end

require_relative "ruby_mod_kit/version"
require_relative "ruby_mod_kit/transpiler"
require_relative "ruby_mod_kit/generation"
require_relative "ruby_mod_kit/memo"
require_relative "ruby_mod_kit/node"
require_relative "ruby_mod_kit/mission"
require_relative "ruby_mod_kit/offset_diff"
