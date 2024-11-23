# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The namespace of transpiler memo.
  module Memo
    class << self
      # @rbs type: String
      # @rbs return: String
      def unify_type(type)
        type[/\A\(([^()]*)\)\z/, 1] || type
      end
    end
  end
end

require_relative "memo/offset_memo"
require_relative "memo/def_parent_memo"
require_relative "memo/ivar_memo"
require_relative "memo/method_memo"
require_relative "memo/parameter_memo"
