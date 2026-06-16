# frozen_string_literal: true

require_relative "test_helper"

class SerpCheapRailsTest < Minitest::Test
  SEARCH = {
    "search" => "best running shoes",
    "page" => 1,
    "organic" => [{ "position" => 1, "title" => "Nike", "link" => "https://nike.test" }]
  }.freeze
  SCRAPE = { "url" => "https://example.test", "title" => "Example" }.freeze
  RANK = {
    "url" => "nike.test", "search" => "best running shoes", "gl" => "us",
    "match_type" => "domain", "pages_scanned" => 1, "found" => true, "rank" => 1,
    "matches" => [{ "rank" => 1, "page" => 1, "position_on_page" => 1, "link" => "https://nike.test", "title" => "Nike" }],
    "organic" => []
  }.freeze

  def setup
    @server = MockServer.new do |path, _body, _headers|
      case path
      when "/v1/search" then [200, SEARCH]
      when "/v1/scrape" then [200, SCRAPE]
      when "/v1/rank" then [200, RANK]
      else [404, { "error" => "not_found" }]
      end
    end
    reset_module!
    SerpCheap::Rails.configure do |c|
      c.api_key = "k"
      c.base_url = @server.base_url
      c.max_retries = 0
      c.cache_store = ActiveSupport::Cache::MemoryStore.new
    end
  end

  def teardown
    @server.stop
    reset_module!
  end

  def reset_module!
    SerpCheap::Rails.instance_variable_set(:@configuration, nil)
    SerpCheap::Rails.reset_client!
  end

  def hits
    @server.requests.size
  end

  def test_search_returns_parsed_results
    res = SerpCheap::Rails.search("best running shoes", gl: "us")
    assert_equal "Nike", res.organic.first.title
    assert_equal 1, hits
  end

  def test_results_are_cached_by_default
    SerpCheap::Rails.search("shoes")
    SerpCheap::Rails.search("shoes")
    assert_equal 1, hits
  end

  def test_distinct_queries_hit_separately
    SerpCheap::Rails.search("shoes")
    SerpCheap::Rails.search("boots")
    assert_equal 2, hits
  end

  def test_caching_can_be_disabled
    SerpCheap::Rails.configuration.cache_enabled = false
    SerpCheap::Rails.reset_client!
    SerpCheap::Rails.search("shoes")
    SerpCheap::Rails.search("shoes")
    assert_equal 2, hits
  end

  def test_without_cache_store_it_bypasses
    SerpCheap::Rails.configuration.cache_store = nil
    SerpCheap::Rails.reset_client!
    SerpCheap::Rails.search("shoes")
    SerpCheap::Rails.search("shoes")
    assert_equal 2, hits
  end

  def test_raw_client_bypasses_cache
    SerpCheap::Rails.raw.search("shoes")
    SerpCheap::Rails.raw.search("shoes")
    assert_equal 2, hits
  end

  def test_scrape_and_rank
    assert_equal "Example", SerpCheap::Rails.scrape("https://example.test").title
    assert_equal 1, SerpCheap::Rails.rank("nike.test", "best running shoes").rank
  end

  def test_missing_api_key_raises
    SerpCheap::Rails.configure { |c| c.api_key = nil }
    error = assert_raises(SerpCheap::Error) { SerpCheap::Rails.search("shoes") }
    assert_equal "missing_api_key", error.error_code
  end

  def test_search_job_warms_the_cache
    SerpCheap::Rails::SearchJob.perform_now("shoes", "gl" => "us")
    assert_equal 1, hits
    SerpCheap::Rails.search("shoes", gl: "us")
    assert_equal 1, hits
  end

  def test_apply_options_overrides_set_keys_only
    SerpCheap::Rails.instance_variable_set(:@configuration, SerpCheap::Rails::Configuration.new)
    SerpCheap::Rails.apply_options(api_key: "k2", timeout_ms: 9000)
    assert_equal "k2", SerpCheap::Rails.configuration.api_key
    assert_equal 9000, SerpCheap::Rails.configuration.timeout_ms
    assert_equal 2, SerpCheap::Rails.configuration.max_retries
  end

  def test_railtie_and_job_types
    assert SerpCheap::Rails::Railtie < ::Rails::Railtie
    assert SerpCheap::Rails::SearchJob < ActiveJob::Base
  end
end
