# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::Node do
  let(:node) { RubyModKit::Node::ProgramNode.new(parse_result).wrap(prism_node) }
  let(:parse_result) { Prism.parse(script).value }

  describe "#name" do
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

  describe "#inspect" do
    let(:script) { "def foo; end" }
    let(:prism_node) { parse_result }

    it "doesn't include redundant values @children, @parent nor @ancestors" do
      child = node.children[0]
      child.ancestors
      expect(child.inspect).not_to include("@parent")
      expect(child.inspect).not_to include("@ancestors")
      expect(node.inspect).not_to include("@children")
    end
  end

  describe "#prism_node" do
    context "with bare Node instance" do
      let(:node) { described_class.new }

      it "raises error" do
        expect { node.prism_node }.to raise_error(RubyModKit::Error)
      end
    end
  end

  describe "#parameter_node_at" do
    let(:script) { "def foo(bar); end" }
    let(:prism_node) { parse_result }

    it do
      expect(node.parameter_node_at(8)).to be_a(RubyModKit::Node::ParameterNode)
    end

    it do
      expect(node.parameter_node_at(0)).to be_nil
    end
  end
end
