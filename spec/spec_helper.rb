# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  track_files "lib/**/*.rb"
  add_filter "/spec/"
  # No coverage measurement as it is read from gemspec.
  add_filter "lib/ruby_mod_kit/version.rb"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true
  config.default_formatter = "doc"
  config.order = :random
  Kernel.srand config.seed

  # config.filter_run_when_matching :focus
  # config.example_status_persistence_file_path = "spec/examples.txt"
  # config.disable_monkey_patching!
  # config.profile_examples = 10
end
