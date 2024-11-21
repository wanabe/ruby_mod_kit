# frozen_string_literal: true

require "ruby_mod_kit/core_ext/eval"

describe RubyModKit::CoreExt::Eval do
  describe ".#eval" do
    let(:rbm_script) { <<~RBM }
      def foo(Integer => n)
        n * 2
      end
      foo(1)
    RBM

    it "evaluates transpiled script" do
      expect(described_class.eval(rbm_script)).to eq(2)
    end
  end
end
