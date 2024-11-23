# frozen_string_literal: true

require "tempfile"
require "rbconfig"
require "ruby_mod_kit"

describe RubyModKit do
  it "has valid version" do
    expect(Gem::Version.correct?(RubyModKit::VERSION)).to be(true)
  end

  describe ".transpile" do
    let(:script) { "some script" }
    let(:generation) { double }

    before do
      allow(RubyModKit::Generation).to receive(:resolve).and_return(generation)
      allow(generation).to receive(:script)
    end

    it "passes script to Generation#resolve" do
      described_class.transpile(script)

      expect(RubyModKit::Generation).to have_received(:resolve).with(script, filename: nil).once
    end
  end

  describe ".transpile_file" do
    let(:rbm_path) { "some path" }
    let(:rbm_script) { "some rbm" }
    let(:rb_script) { "some rb" }

    before do
      allow(described_class).to receive(:transpile).and_return(rb_script)
      allow(File).to receive(:read).and_return(rbm_script)
      allow(File).to receive(:write)
    end

    it "passes script to .transpile" do
      described_class.transpile_file(rbm_path)

      expect(File).to have_received(:read).with(rbm_path).once
      expect(described_class).to have_received(:transpile).with(rbm_script, filename: rbm_path).once
      expect(File).not_to have_received(:write)
    end

    it "writes ruby script with given io" do
      allow($stdout).to receive(:write)
      described_class.transpile_file(rbm_path, output: $stdout)

      expect(File).to have_received(:read).with(rbm_path).once
      expect(described_class).to have_received(:transpile).with(rbm_script, filename: rbm_path).once
      expect($stdout).to have_received(:write).with(rb_script)
      expect(File).not_to have_received(:write)
    end

    it "writes ruby script with given path" do
      rb_path = "some rb path"
      described_class.transpile_file(rbm_path, output: rb_path)

      expect(File).to have_received(:read).with(rbm_path).once
      expect(described_class).to have_received(:transpile).with(rbm_script, filename: rbm_path).once
      expect(File).to have_received(:write).with(rb_path, rb_script)
    end
  end

  describe ".execute_file" do
    let(:tmpdir) { +"" }
    let(:rbm_path) { File.join(tmpdir, "scr.rbm") }
    let(:rb_path) { File.join(tmpdir, "scr.rb") }
    let(:rbm_script) { "rbm script" }
    let(:rb_script) { "rb script" }
    let(:generation) { double }

    around do |example|
      Dir.mktmpdir do |dir|
        tmpdir.replace(dir)
        example.run
      end
    end

    before do
      allow(RubyModKit::Generation).to receive(:resolve).and_return(generation)
      allow(generation).to receive(:script).and_return(rb_script)
      allow(described_class).to receive(:eval)
      allow(described_class).to receive(:system)
      File.write(rbm_path, rbm_script)
    end

    it "evaluates ruby script" do
      described_class.execute_file(rbm_path)

      expect(RubyModKit::Generation).to have_received(:resolve).with(rbm_script, filename: instance_of(String)).once
      expect(described_class).to have_received(:eval).with(rb_script, TOPLEVEL_BINDING)
    end

    it "creates .rb from .rbm" do
      described_class.execute_file(rbm_path, output: rb_path)

      expect(RubyModKit::Generation).to have_received(:resolve).with(rbm_script, filename: instance_of(String)).once
      expect(described_class).to have_received(:system).with(RbConfig.ruby, rb_path)
    end
  end
end
