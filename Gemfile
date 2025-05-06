# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in packwerk.gemspec
gemspec

# We're testing with Rails 3.2
gem("rails", "~> 3.2.22")

# Add polyfills for Rails 3.2 compatibility
gem("backports", require: false)
gem("test-unit", "~> 3.0")

# Development and test dependencies
group :development, :test do
  # Lock to older versions compatible with Ruby 2.3.8
  gem("byebug", "~> 9.0.0", platforms: %i(mri mingw x64_mingw))
  gem("mocha", "< 2", require: false)
  gem("minitest-focus")
  gem("m")
  
  # Lock rake to a compatible version
  gem("rake", "< 13.0")
  
  # Removing rubocop for initial compatibility testing
  # gem("rubocop", "0.93.1", require: false)
  # gem("rubocop-performance", "1.8.1", require: false)
  # gem("rubocop-shopify", "1.0.5", require: false)
end
