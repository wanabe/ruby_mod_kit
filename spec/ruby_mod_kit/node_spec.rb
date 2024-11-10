# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node do
  describe "#name" do
    let(:node) { described_class.new(prism_node) }
    let(:parse_result) { Prism.parse(script).value }

    context "with Prism::DefNode" do
      let(:script) { "def foo; end" }
      let(:prism_node) { parse_result.statements.body[0] }

      it "returns method name" do
        expect(node.name).to eq(:foo)
      end
    end

    context "with Prism::StatementsNode" do
      let(:script) { "def foo; end" }
      let(:prism_node) { parse_result.statements }

      it "raises an exception" do
        expect { node.name }.to raise_error(RubyModKit::Error)
      end
    end

    context "with Prism::RequiredParameterNode" do
      let(:script) { "def foo(bar); end" }
      let(:prism_node) { parse_result.statements.body[0].parameters.requireds[0] }

      it "returns parameter name" do
        expect(node.name).to eq(:bar)
      end
    end
  end
end
