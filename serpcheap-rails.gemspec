# frozen_string_literal: true

require_relative "lib/serpcheap/rails/version"

Gem::Specification.new do |spec|
  spec.name = "serpcheap-rails"
  spec.version = SerpCheap::Rails::VERSION
  spec.authors = ["serp.cheap"]
  spec.summary = "Rails integration for the serp.cheap Google Search API."
  spec.description = "Railtie, cached client (Rails.cache), credentials/ENV config, and an ActiveJob for the serp.cheap SERP API."
  spec.homepage = "https://serp.cheap"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "homepage_uri" => "https://serp.cheap",
    "source_code_uri" => "https://github.com/SerpCheap/serpcheap-rails",
    "documentation_uri" => "https://serp.cheap/docs",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activejob", ">= 6.1"
  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "railties", ">= 6.1"
  spec.add_dependency "serpcheap", "~> 0.2"
end
