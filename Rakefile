# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"

require "rubocop/rake_task"
require "steep/rake_task"
require "rbs/inline"
require "rbs/inline/cli"
require "ruby_mod_kit"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new

Steep::RakeTask.new

desc "Generate RBS files from annotations"
task :rbs_inline do
  RBS::Inline::CLI.new.run(%w[--output lib])
end

desc "Transpile .rbm files under lib/"
task lib: Dir.glob("lib/**/*.rbm").map { _1.ext(".rb") }
rule ".rb" => %w[.rbm] do |t|
  RubyModKit.transpile_file(t.source)
end

desc "Check untyped in rbs"
task :rbs_typed do
  untyped_found = false
  Dir.glob("sig/generated/**/*.rbs") do |path|
    File.open(path) do |f|
      f.each_line do |l|
        if l =~ /untyped(?! _)/
          untyped_found = true
          warn "#{path}:#{l}"
        end
      end
    end
  end
  raise "untyped found" if untyped_found
end

task default: %i[lib test rbs_inline rbs_typed rubocop:autocorrect_all steep:check]
