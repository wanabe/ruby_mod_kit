# frozen_string_literal: true

require "ruby_mod_kit/corrector"

describe RubyModKit::Corrector do
  let(:corrector) { described_class.new }

  describe "#correctable_error_types" do
    it "returns empty array" do
      expect(corrector.correctable_error_types).to eq([])
    end
  end

  describe "#correct" do
    let(:parse_error) { parse_result.errors.first }
    let(:generation) { RubyModKit::Generation.new("") }
    let(:parse_result) { Prism.parse("@") }
    let(:root_node) { RubyModKit::Node::ProgramNode.new(parse_result.value) }
    let(:memo_pad) { RubyModKit::MemoPad.new }

    it "raises an exception" do
      expect { corrector.correct(parse_error, generation, root_node, memo_pad) }.to raise_error(RubyModKit::Error)
    end
  end
end