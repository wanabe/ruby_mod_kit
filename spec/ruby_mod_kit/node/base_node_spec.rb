# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node::BaseNode do
  let(:node) { described_class.new }

  describe "#prism_node" do
    it "raises error" do
      expect { node.prism_node }.to raise_error(RubyModKit::Error)
    end
  end

  describe "#parent" do
    it "raises error" do
      expect { node.parent }.to raise_error(RubyModKit::Error)
    end
  end
end
