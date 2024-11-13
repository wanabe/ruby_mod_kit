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

desc "Transpile .rbm files under lib/"
task :lib do
  Dir.glob("lib/**/*.rbm") do |rbm_path|
    RubyModKit.transpile_file(rbm_path)
  end
end

desc "Check untyped in rbs"
task :rbs_typed do
  untyped_found = false
  Dir.glob("sig/generated/**/*.rbs") do |path|
    File.open(path) do |f|
      f.each_line do |l|
        if l =~ / untyped(?! _)/
          untyped_found = true
          warn "#{path}:#{l}"
        end
      end
    end
  end
  raise "untyped found" if untyped_found
end

task default: %i[lib spec rbs_inline rbs_typed rubocop:autocorrect_all steep:check]
