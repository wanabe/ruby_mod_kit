# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Mission do
  let(:mission) { described_class.new }

  describe "#perform" do
    let(:generation) { RubyModKit::Generation.new("") }
    let(:root_node) { RubyModKit::Node::ProgramNode.new(parse_result.value) }
    let(:parse_result) { Prism.parse("") }
    let(:memo_pad) { RubyModKit::MemoPad.new }
    let(:args) { [generation, root_node, parse_result, memo_pad] }

    it "raises an exception that points out as unexpected" do
      expect { mission.perform(*args) }.to raise_error(RubyModKit::Error, /Unexpected type/)
    end
  end
end
