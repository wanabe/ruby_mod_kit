# frozen_string_literal: true

# rbs_inline: enabled

require "rbmk"
require "thor"

module Rbmk
  # This class provides CLI commands of rbmk.
  class CLI < Thor
    desc "exec", "execute rbm file"
    # @rbs *args: String
    # @rbs return: void
    def exec(*args)
      Rbmk.execute_file(*args)
    end

    desc "transpile", "transpile rbm files"
    # @rbs *args: String
    # @rbs return: void
    def transpile(*args)
      args.each do |path|
        Rbmk.transpile_file(path)
      end
    end
  end
end
