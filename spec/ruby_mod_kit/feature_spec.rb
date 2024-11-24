# frozen_string_literal: true

require "ruby_mod_kit/feature"

describe RubyModKit::Feature do
  let(:feature) { described_class.new }

  describe "#create_correctors" do
    it "returns empty array" do
      expect(feature.create_correctors).to eq([])
    end
  end

  describe "#create_missions" do
    it "returns empty array" do
      expect(feature.create_missions).to eq([])
    end
  end
end
