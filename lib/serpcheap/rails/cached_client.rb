# frozen_string_literal: true

require "digest"
require "json"

module SerpCheap
  module Rails
    class CachedClient
      def initialize(sdk, configuration)
        @sdk = sdk
        @configuration = configuration
      end

      def raw
        @sdk
      end

      def search(query, **opts)
        fetch("search", [query, opts]) { @sdk.search(query, **opts) }
      end

      def scrape(url, **opts)
        fetch("scrape", [url, opts]) { @sdk.scrape(url, **opts) }
      end

      def rank(url, query, **opts)
        fetch("rank", [url, query, opts]) { @sdk.rank(url, query, **opts) }
      end

      private

      def fetch(kind, key_parts)
        store = @configuration.cache_store
        return yield unless @configuration.cache_enabled && store

        key = "serpcheap:#{kind}:#{Digest::MD5.hexdigest(JSON.generate(normalize(key_parts)))}"
        store.fetch(key, expires_in: @configuration.cache_ttl) { yield }
      end

      def normalize(value)
        case value
        when Hash then value.sort_by { |k, _| k.to_s }.to_h.transform_values { |v| normalize(v) }
        when Array then value.map { |v| normalize(v) }
        else value
        end
      end
    end
  end
end
