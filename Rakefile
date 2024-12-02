# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rubocop/rake_task"
require "steep/rake_task"
require "rspec/core/rake_task"
require "rbs/inline"
require "rbs/inline/cli"
require "ruby_mod_kit"

RuboCop::RakeTask.new

Steep::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

desc "Generate RBS files from annotations"
task :rbs_inline do
  RBS::Inline::CLI.new.run(%w[--output lib])
end

desc "Transpile .rbm files under lib/ and clean other .rb files"
task :lib do
  rb_paths = Set.new(Dir.glob("lib/**/*.rb"))
  Dir.glob("lib/**/*.rbm") do |rbm_path|
    rb_path = RubyModKit.rb_path(rbm_path)
    rb_paths.delete(rb_path)
    RubyModKit.transpile_file(rbm_path, output: rb_path, config: RubyModKit::Config.load(".", if_none: nil))
  end
  File.unlink(*rb_paths)
end

desc "Clean generated .rbs files"
task :clean_rbs do
  File.unlink(*Dir.glob("sig/generated/**/*.rbs"))
end

desc "Check untyped in rbs"
task :rbs_typed do
  untyped_found = false
  Dir.glob("sig/generated/**/*.rbs") do |path|
    File.open(path) do |f|
      f.each_line do |l|
        if l =~ / \??untyped(?! _|\?)/
          untyped_found = true
          warn "#{path}:#{l}"
        end
      end
    end
  end
  raise "untyped found" if untyped_found
end

desc "Check git tag"
task :tag do
  tag = "v#{RubyModKit::VERSION}"
  unless system("git tag --points-at HEAD|grep '^#{tag}$'")
    system("git tag #{tag}") || raise
    system("bundle")
  end

  unless system("git diff-index --quiet HEAD")
    system("git status")
    raise
  end
end

gem_file = "ruby_mod_kit-#{RubyModKit::VERSION}.gem"
file gem_file => :tag do
  system("gem build ruby_mod_kit.gemspec") || raise
end

desc "Push gem file to rubygems.org"
task push_gem: gem_file do
  system("gem push #{gem_file}") || raise
end

desc "Push git branches and tags"
task :push_git do
  puts "pushing: #{`git branch --show`.chomp}"
  raise "Unexpected diff detected" unless system("git diff --exit-code")

  system("git push --follow-tags")
end
task push: %i[push_gem push_git]

task default: %i[lib spec clean_rbs rbs_inline rbs_typed rubocop:autocorrect_all steep:check]
