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

    it "calls RubyModKit.transpile_file with stdout by default" do
      cli.transpile(*args)
      expect(RubyModKit).to have_received(:transpile_file).with("script1.rbm", output: $stdout).once
      expect(RubyModKit).to have_received(:transpile_file).with("script2.rbm", output: $stdout).once
    end

    it "outputs .rb file with --output=.rb" do
      cli.invoke(:transpile, args, output: ".rb")
      expect(RubyModKit).to have_received(:transpile_file).with("script1.rbm", output: "script1.rb").once
      expect(RubyModKit).to have_received(:transpile_file).with("script2.rbm", output: "script2.rb").once
    end

    it "outputs fixed file with --output=path/to/file" do
      cli.invoke(:transpile, args, output: "some_file")
      expect(RubyModKit).to have_received(:transpile_file).with("script1.rbm", output: "some_file").once
      expect(RubyModKit).to have_received(:transpile_file).with("script2.rbm", output: "some_file").once
    end
  end
end
