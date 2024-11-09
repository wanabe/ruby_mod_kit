# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in ruby_mod_kit.gemspec
gemspec

group :development do
  gem "debug"
  gem "rake", "~> 13.0"
end

group :lint do
  gem "rbs-inline", require: false
  gem "rubocop", "~> 1.21"
  gem "rubocop-on-rbs", "~> 1.1", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "steep"
end

group :test do
  gem "rspec", "~> 3.13"
  gem "simplecov"
end
