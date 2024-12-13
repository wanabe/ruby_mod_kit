# frozen_string_literal: true

require "tmpdir"

describe "ruby_mod_kit command" do
  let(:root_dir) { File.absolute_path("../..", __dir__) }

  around(:all) do |each|
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        gem_home = File.absolute_path("../..", ENV.fetch("GEM_HOME", nil))
        Bundler.with_unbundled_env do
          system("bundle config --local path '#{gem_home}'")
          File.write("Gemfile", <<~GEMFILE)
            gem "ruby_mod_kit",  path: "#{root_dir}"
          GEMFILE
          each.run
        end
      end
    end
  end

  describe "transpile" do
    it "transpiles rbm script" do
      result = `bundle exec ruby_mod_kit transpile #{root_dir}/examples/user.rbm`
      expect(result).to eq(File.read("#{root_dir}/examples/user.rb"))
    end
  end

  describe "exec" do
    it "executes rbm script" do
      result = `bundle exec ruby_mod_kit exec #{root_dir}/examples/user.rbm`
      expect(result).to eq(<<~OUTPUT)
        a@exmple.com
        3
        11
        #<Pos: (3, 6, 0)>
      OUTPUT
    end
  end
end
