# frozen_string_literal: true

require "active_job"

module SerpCheap
  module Rails
    # Warms the result cache off the request cycle:
    #   SerpCheap::Rails::SearchJob.perform_later("best running shoes", "gl" => "br")
    class SearchJob < ActiveJob::Base
      def perform(query, opts = {})
        SerpCheap::Rails.search(query, **symbolize(opts))
      end

      private

      def symbolize(opts)
        opts.each_with_object({}) { |(k, v), out| out[k.to_sym] = v }
      end
    end
  end
end
