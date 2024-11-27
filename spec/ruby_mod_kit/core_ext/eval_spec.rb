# frozen_string_literal: true

require "ruby_mod_kit/core_ext/eval"

describe RubyModKit::CoreExt::Eval do
  describe ".#eval" do
    it "evaluates transpiled script" do
      expect(described_class.eval(<<~RBM)).to eq(2)
        def foo(Integer => n)
          n * 2
        end
        foo(1)
      RBM
    end

    it "evaluates under TOPLEVEL_BINDING by default" do
      expect(described_class.eval("self")).to eq(TOPLEVEL_BINDING.receiver)
    end

    it "evaluates under given binding" do
      expect(described_class.eval("self", binding)).to eq(self)
    end
  end
end
