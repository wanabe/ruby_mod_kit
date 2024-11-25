# frozen_string_literal: true

require "ruby_mod_kit/cli"

describe RubyModKit::CLI do
  let(:cli) { described_class.new }
  let(:config) { double }

  before do
    allow(RubyModKit::Config).to receive(:load).and_return(config)
  end

  describe "#exec" do
    let(:args) { %w[script.rbm arg1 arg2] }

    before do
      allow(RubyModKit).to receive(:execute_file)
    end

    it "calls RubyModKit.execute_file" do
      cli.exec(*args)
      expect(RubyModKit).to have_received(:execute_file).with(*args, config: config).once
      expect(RubyModKit::Config).to have_received(:load).with(".", if_none: nil)
    end

    it "sets up config with --config=/path" do
      cli.invoke(:exec, args, config: "/path")
      expect(RubyModKit).to have_received(:execute_file).with(*args, config: config).once
      expect(RubyModKit::Config).to have_received(:load).with("/path", if_none: :raise)
    end
  end

  describe "#transpile" do
    let(:args) { %w[script1.rbm script2.rbm] }

    before do
      allow(RubyModKit).to receive(:transpile_file)
    end

    it "calls RubyModKit.transpile_file with stdout by default" do
      cli.transpile(*args)
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script1.rbm", output: $stdout, config: config).once
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script2.rbm", output: $stdout, config: config).once
      expect(RubyModKit::Config).to have_received(:load).with(".", if_none: nil)
    end

    it "outputs .rb file with --output=.rb" do
      cli.invoke(:transpile, args, output: ".rb")
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script1.rbm", output: "script1.rb", config: config).once
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script2.rbm", output: "script2.rb", config: config).once
      expect(RubyModKit::Config).to have_received(:load).with(".", if_none: nil)
    end

    it "outputs fixed file with --output=path/to/file" do
      cli.invoke(:transpile, args, output: "some_file")
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script1.rbm", output: "some_file", config: config).once
      expect(RubyModKit).to have_received(:transpile_file)
        .with("script2.rbm", output: "some_file", config: config).once
      expect(RubyModKit::Config).to have_received(:load).with(".", if_none: nil)
    end
  end
end
