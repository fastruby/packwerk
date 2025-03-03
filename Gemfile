# frozen_string_literal: true

source("https://rubygems.org")
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gemspec

# Specify the same dependency sources as the application Gemfile

gem("spring")
gem("backports")
gem("ruby-next-core")
gem("rails", "~> 5.0.2")
gem("constant_resolver", require: false)
# gem("sorbet-runtime", require: false)
# gem("rubocop-performance", require: false)
# gem("rubocop-sorbet", require: false)
gem("mocha", "~> 1.12.0", require: false)
gem 'test-unit', '~> 3.0'
# gem("rubocop-shopify", require: false)
# gem("tapioca", require: false)

group :development do
  gem("m", "1.6.1", require: false)
  gem("byebug", require: false)
  gem("minitest-focus", require: false)
end
