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
    let(:transpiler) { double }

    before do
      allow(RubyModKit::Transpiler).to receive(:new).and_return(transpiler)
      allow(transpiler).to receive(:transpile)
    end

    it "passes script to Transpiler#transpile" do
      described_class.transpile(script)

      expect(RubyModKit::Transpiler).to have_received(:new).with(no_args).once
      expect(transpiler).to have_received(:transpile).with(script, filename: nil).once
    end
  end

  describe ".execute_file" do
    let(:tmpdir) { +"" }
    let(:rbm_path) { File.join(tmpdir, "scr.rbm") }
    let(:rb_path) { File.join(tmpdir, "scr.rb") }
    let(:rbm_script) { "rbm script" }
    let(:rb_script) { "rb script" }
    let(:transpiler) { double }

    around do |example|
      Dir.mktmpdir do |dir|
        tmpdir.replace(dir)
        example.run
      end
    end

    before do
      allow(RubyModKit::Transpiler).to receive(:new).and_return(transpiler)
      allow(transpiler).to receive(:transpile).and_return(rb_script)
      allow(described_class).to receive(:eval)
      allow(described_class).to receive(:system)
      File.write(rbm_path, rbm_script)
    end

    it "evaluates ruby script" do
      described_class.execute_file(rbm_path)

      expect(RubyModKit::Transpiler).to have_received(:new).with(no_args).once
      expect(transpiler).to have_received(:transpile).with(rbm_script, filename: instance_of(String)).once
      expect(described_class).to have_received(:eval).with(rb_script, TOPLEVEL_BINDING)
    end

    it "creates .rb from .rbm" do
      described_class.execute_file(rbm_path, output: rb_path)

      expect(RubyModKit::Transpiler).to have_received(:new).with(no_args).once
      expect(transpiler).to have_received(:transpile).with(rbm_script, filename: instance_of(String)).once
      expect(described_class).to have_received(:system).with(RbConfig.ruby, rb_path)
    end
  end
end
