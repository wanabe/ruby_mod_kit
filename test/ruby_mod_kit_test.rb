# frozen_string_literal: true

require "test_helper"

class RubyModKitTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::RubyModKit.const_defined?(:VERSION)
    end
  end
end
