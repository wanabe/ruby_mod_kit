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
    let(:tempfile) { Tempfile.open(["scr", ".rbm"]) }
    let(:script) { "some script" }
    let(:transpiler) { double }
    let(:rbm_path) { tempfile.path }

    before do
      allow(RubyModKit::Transpiler).to receive(:new).and_return(transpiler)
      allow(transpiler).to receive(:transpile).and_return(script)
      allow(described_class).to receive(:system)
      tempfile.write(script)
      tempfile.flush
    end

    after do
      tempfile.close(true)
    end

    it "creates .rb from .rbm" do
      described_class.execute_file(rbm_path)

      expect(RubyModKit::Transpiler).to have_received(:new).with(no_args).once
      expect(transpiler).to have_received(:transpile).with(script, filename: instance_of(String)).once
      expect(described_class).to have_received(:system).with(RbConfig.ruby, match(/\.rb\z/))
    end
  end
end
