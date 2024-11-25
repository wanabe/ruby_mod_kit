# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node::BaseNode do
  let(:node) { described_class.new }

  describe "#parent" do
    it "raises error" do
      expect { node.parent }.to raise_error(RubyModKit::Error)
    end
  end
end
