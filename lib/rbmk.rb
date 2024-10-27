# frozen_string_literal: true

# rbs_inline: enabled

require "rbconfig"

require_relative "rbmk/version"
require_relative "rbmk/transpiler"

# The root namespace for rbmk.
module Rbmk
  class Error < StandardError; end

  class << self
    # @rbs file: String
    # @rbs *args: String
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
      Transpiler.new(src).transpile
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
  end
end
