# frozen_string_literal: true

module SerpCheap
  module Rails
    class Configuration
      attr_accessor :api_key, :base_url, :timeout_ms, :max_retries,
                    :cache_enabled, :cache_ttl, :cache_store

      def initialize
        @api_key = ENV.fetch("SERPCHEAP_API_KEY", nil)
        @base_url = ENV.fetch("SERPCHEAP_BASE_URL", nil)
        @timeout_ms = 15_000
        @max_retries = 2
        @cache_enabled = true
        @cache_ttl = 3600
        @cache_store = nil
      end
    end
  end
end
