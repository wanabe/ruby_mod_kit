# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Mission do
  let(:mission) { described_class.new }

  describe "#perform" do
    let(:generation) { RubyModKit::Generation.new("") }

    it "raises an exception that points out as unexpected" do
      expect { mission.perform(generation) }.to raise_error(RubyModKit::Error, /Unexpected type/)
    end
  end
end
