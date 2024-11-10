# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::CLI do
  let(:cli) { described_class.new }

  describe "#exec" do
    let(:args) { %w[script.rbm arg1 arg2] }

    before do
      allow(RubyModKit).to receive(:execute_file)
    end

    it "calls RubyModKit.execute_file" do
      cli.exec(*args)
      expect(RubyModKit).to have_received(:execute_file).with(*args).once
    end
  end

  describe "#transpile" do
    let(:args) { %w[script1.rbm script2.rbm] }

    before do
      allow(RubyModKit).to receive(:transpile_file)
    end

    it "calls RubyModKit.transpile_file" do
      cli.transpile(*args)
      expect(RubyModKit).to have_received(:transpile_file).with(args[0]).once
      expect(RubyModKit).to have_received(:transpile_file).with(args[1]).once
    end
  end
end
