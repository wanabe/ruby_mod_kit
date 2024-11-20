# frozen_string_literal: true

require_relative "lib/ruby_mod_kit/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_mod_kit"
  spec.version = RubyModKit::VERSION
  spec.authors = ["wanabe"]
  spec.email = ["s.wanabe@gmail.com"]

  spec.summary = "ruby_mod_kit"
  spec.description = "ruby_mod_kit"
  spec.homepage = "https://github.com/wanabe/ruby_mod_kit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      next true if File.expand_path(f) == __FILE__
      next false if f =~ %r{\Aexamples/.*rbm?\z}
      next true if f.start_with?(*%w[bin/ test/ spec/ features/ coverage/ bin/ .git])
      next true if %w[Gemfile Gemfile.lock .rspec .rubocop.yml Rakefile Steepfile].include?(f)
      next true if f.end_with?(".rbm")

      false
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "prism", "~> 1.0"
  spec.add_dependency "thor", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
