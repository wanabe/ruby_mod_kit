# frozen_string_literal: true

require "ruby_mod_kit/core_ext/load"
require "tmpdir"

describe RubyModKit::CoreExt::Load do
  describe ".load_path" do
    it "equals $LOAD_PATH" do
      expect(described_class.load_path.object_id).to eq($LOAD_PATH.object_id)
    end
  end

  describe ".loaded_features" do
    it "equals $LOADED_FEATURES" do
      expect(described_class.loaded_features.object_id).to eq($LOADED_FEATURES.object_id)
    end
  end

  describe ".#require" do
    let(:tmpdir) { +"" }
    let(:name) { "some_file_for_test" }
    let(:path) { "#{tmpdir}/#{name}.rbm" }
    let(:rbm_script) { <<~RBM }
      def foo(Integer => bar)
      end
      foo(1)
    RBM
    let(:rb_script) { <<~RB }
      # @rbs bar: Integer
      def foo(bar)
      end
      foo(1)
    RB

    around do |example|
      Dir.mktmpdir do |dir|
        tmpdir.replace(dir)
        example.run
      end
    end

    before do
      File.write(path, rbm_script)
      allow(described_class).to receive_messages(load_path: [tmpdir], loaded_features: [])
      allow(described_class).to receive(:eval)
    end

    it "evaluates transpiled script" do
      described_class.require(name)
      expect(described_class).to have_received(:eval).with(rb_script, TOPLEVEL_BINDING, path)
    end

    it "allows filename with ext" do
      described_class.require("#{name}.rbm")
      expect(described_class).to have_received(:eval).with(rb_script, TOPLEVEL_BINDING, path)
    end
  end
end
