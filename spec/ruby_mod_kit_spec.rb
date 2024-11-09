# frozen_string_literal: true

describe RubyModKit do
  it "has valid version" do
    expect(Gem::Version.correct?(RubyModKit::VERSION)).to be(true)
  end
end
