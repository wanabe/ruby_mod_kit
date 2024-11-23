# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node::BaseNode do
  describe "#prism_node" do
    context "with bare Node instance" do
      let(:node) { described_class.new }

      it "raises error" do
        expect { node.prism_node }.to raise_error(RubyModKit::Error)
      end
    end
  end
end
