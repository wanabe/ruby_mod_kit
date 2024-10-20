# frozen_string_literal: true

require "test_helper"

class RbmkTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Rbmk.const_defined?(:VERSION)
    end
  end
end
