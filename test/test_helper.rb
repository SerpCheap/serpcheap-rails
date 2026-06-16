# frozen_string_literal: true

begin
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    add_filter "railtie" # boot glue; needs a real Rails app to exercise
    minimum_coverage 90 if ENV["COVERAGE_GATE"]
  end
rescue LoadError
  raise if ENV["COVERAGE_GATE"]
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# A booted Rails app loads these before any railtie; a bare test process does not.
require "active_support"
require "active_support/core_ext/module/delegation"
require "active_support/cache"

require "serpcheap/rails"
require "minitest/autorun"
require_relative "support/mock_server"
