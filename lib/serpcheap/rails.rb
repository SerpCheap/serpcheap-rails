# frozen_string_literal: true

require "serpcheap"

require_relative "rails/version"
require_relative "rails/configuration"
require_relative "rails/cached_client"

module SerpCheap
  # Rails integration: a Railtie wires config + Rails.cache; SerpCheap::Rails
  # exposes a cached search/scrape/rank facade and a raw client escape hatch.
  module Rails
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration) if block_given?
        reset_client!
        configuration
      end

      def apply_options(options)
        c = configuration
        c.api_key = options[:api_key] unless options[:api_key].nil?
        c.base_url = options[:base_url] unless options[:base_url].nil?
        c.timeout_ms = options[:timeout_ms] unless options[:timeout_ms].nil?
        c.max_retries = options[:max_retries] unless options[:max_retries].nil?
        c.cache_store = options[:cache_store] unless options[:cache_store].nil?
        c.cache_enabled = options[:cache_enabled] unless options[:cache_enabled].nil?
        c.cache_ttl = options[:cache_ttl] unless options[:cache_ttl].nil?
        reset_client!
        c
      end

      def reset_client!
        @client = nil
      end

      def client
        @client ||= build_client
      end

      def raw
        client.raw
      end

      def search(query, **opts)
        client.search(query, **opts)
      end

      def scrape(url, **opts)
        client.scrape(url, **opts)
      end

      def rank(url, query, **opts)
        client.rank(url, query, **opts)
      end

      private

      def build_client
        c = configuration
        if c.api_key.nil? || c.api_key.empty?
          raise SerpCheap::Error.new(
            "missing_api_key",
            "Set SerpCheap::Rails api_key (or SERPCHEAP_API_KEY). Get a key at https://app.serp.cheap."
          )
        end
        sdk = SerpCheap::Client.new(
          c.api_key,
          base_url: c.base_url,
          timeout_ms: c.timeout_ms,
          max_retries: c.max_retries
        )
        CachedClient.new(sdk, c)
      end
    end
  end
end

require_relative "rails/railtie"
require_relative "rails/search_job"
