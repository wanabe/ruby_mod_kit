# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node::ParameterNode do
  describe ".new" do
    let(:parse_result) { Prism.parse(script).value }
    let(:script) { "def foo(bar); end" }
    let(:prism_node) { parse_result.statements.body[0].parameters.requireds[0] }

    it "returns an instance if parameter node is given" do
      expect(described_class.new(prism_node, parent: parse_result)).to be_an_instance_of(described_class)
    end

    it "raises an error if non-parameter node is given" do
      expect { described_class.new(parse_result, parent: parse_result) }.to raise_error(RubyModKit::Error)
    end
  end
end
