# serpcheap-rails

Rails integration for the [serp.cheap](https://serp.cheap) **Google Search API** — real-time Google SERP data (organic results, ads, knowledge graph, page scraping, rank tracking) wrapped with a Railtie, `Rails.cache` result caching, credentials/ENV config, and an ActiveJob.

It's the **cheapest Google Search API** we know of — $0.0003 per cached search, $0.0006 fresh, no monthly minimum (~10× cheaper than SerpApi).

## Install

```ruby
# Gemfile
gem "serpcheap-rails"
```

Set your API key (get one at [app.serp.cheap](https://app.serp.cheap)) via `SERPCHEAP_API_KEY`, Rails credentials, or an initializer:

```ruby
# config/initializers/serpcheap.rb
SerpCheap::Rails.configure do |c|
  c.api_key = Rails.application.credentials.serpcheap_api_key
  # c.cache_ttl = 3600
  # c.cache_enabled = true
end
```

You can also configure it the Rails way in any environment file:

```ruby
config.serpcheap.api_key = ENV["SERPCHEAP_API_KEY"]
config.serpcheap.cache_ttl = 1.hour
```

## Usage

```ruby
results = SerpCheap::Rails.search("best running shoes", gl: "us")
page    = SerpCheap::Rails.scrape("https://example.com")
rank    = SerpCheap::Rails.rank("example.com", "best running shoes")
```

Results are cached in `Rails.cache` by default (keyed by query + options) so repeat calls don't spend credits. Reach the raw, uncached SDK client when you need it:

```ruby
SerpCheap::Rails.raw.search_pages("best running shoes", from: 1, to: 3)
```

### Background cache warming

Pre-warm the cache off the request cycle with the bundled ActiveJob:

```ruby
SerpCheap::Rails::SearchJob.perform_later("best running shoes", "gl" => "br")
```

## Configuration

| Setting | Default | Description |
| --- | --- | --- |
| `api_key` | `ENV["SERPCHEAP_API_KEY"]` | API key (required) |
| `base_url` | `https://api.serp.cheap` | API base URL |
| `timeout_ms` | `15000` | Per-request timeout |
| `max_retries` | `2` | Retry count on transient errors |
| `cache_enabled` | `true` | Toggle `Rails.cache` result caching |
| `cache_store` | `Rails.cache` | Any `ActiveSupport::Cache::Store` |
| `cache_ttl` | `3600` | Cache TTL in seconds |

## License

MIT
