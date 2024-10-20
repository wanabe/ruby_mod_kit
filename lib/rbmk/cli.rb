# frozen_string_literal: true

require "rbmk"
require "thor"

module Rbmk
  # This class provides CLI commands of rbmk.
  class CLI < Thor
    desc "exec", "execute rbm file"
    def exec(...)
      Rbmk.execute_file(...)
    end
  end
end
