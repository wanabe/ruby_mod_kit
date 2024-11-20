# frozen_string_literal: true

# rbs_inline: enabled

require "ruby_mod_kit"
require "thor"

module RubyModKit
  # This class provides CLI commands of ruby_mod_kit.
  class CLI < Thor
    desc "exec", "execute rbm file"
    # @rbs *args: String
    # @rbs return: void
    def exec(*args)
      RubyModKit.execute_file(*args)
    end

    desc "transpile", "transpile rbm files"
    method_option :output, type: :string
    # @rbs *args: String
    # @rbs return: void
    def transpile(*args)
      output = case options[:output]
      when nil, "-", "/dev/stdout"
        $stdout
      when ".rb"
        nil
      else
        options[:output]
      end
      args.each do |path|
        RubyModKit.transpile_file(path, output: output || RubyModKit.rb_path(path))
      end
    end
  end
end
