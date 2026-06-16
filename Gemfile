# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "serpcheap", path: "../sdk-ruby"

rails_version = ENV.fetch("RAILS_VERSION", nil)
if rails_version
  gem "activejob", rails_version
  gem "activesupport", rails_version
  gem "railties", rails_version
end

gem "minitest", "~> 5.0"
gem "rake", "~> 13.0"
gem "simplecov", "~> 0.22", require: false
