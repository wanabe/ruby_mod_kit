# frozen_string_literal: true

require "ruby_mod_kit/config"
require "tmpdir"

describe RubyModKit::Config do
  describe ".load" do
    let(:tmpdir) { +"" }

    around do |example|
      Dir.mktmpdir do |dir|
        tmpdir.replace(dir)
        example.run
      end
    end

    context "with config file" do
      before do
        File.write(File.join(tmpdir, ".ruby_mod_kit.yml"), "features: []")
      end

      it "returns Config instance" do
        expect(described_class.load(tmpdir, if_none: nil)).to be_instance_of(described_class)
      end
    end

    context "without config file" do
      it "returns nil when if_none: nil" do
        expect(described_class.load(tmpdir, if_none: nil)).to be_nil
      end

      it "raises LoadError when if_none: :raise" do
        expect do
          described_class.load(tmpdir, if_none: :raise)
        end.to raise_error(LoadError, include("Can't load #{tmpdir}"))
      end

      it "doesn't allow unknown if_none type" do
        expect do
          described_class.load(tmpdir, if_none: :invalid)
        end.to raise_error(ArgumentError, include("unexpected"))
      end
    end
  end
end
