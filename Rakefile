# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"

require "rubocop/rake_task"
require "steep/rake_task"
require "rbs/inline"
require "rbs/inline/cli"

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

task default: %i[test rbs_inline rubocop:autocorrect_all steep:check]
