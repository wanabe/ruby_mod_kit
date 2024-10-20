# frozen_string_literal: true

require_relative "rbmk/version"
require "rbconfig"

# The root namespace for rbmk.
module Rbmk
  class Error < StandardError; end

  module_function

  def execute_file(file, *args)
    rb_file = transpile_file(file)
    execute_rb_file(rb_file, *args)
  end

  def transpile_file(file)
    rb_src = transpile(File.read(file))
    rb_path = rb_path(file)
    File.write(rb_path, rb_src)
    rb_path
  end

  def transpile(src)
    src
  end

  def execute_rb_file(file, *args)
    system(RbConfig.ruby, file, *args)
  end

  def rb_path(path)
    path.sub(/(?:\.rbm)?$/, ".rb")
  end
end
