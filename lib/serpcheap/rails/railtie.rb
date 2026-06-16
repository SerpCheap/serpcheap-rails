# frozen_string_literal: true

require "rails/railtie"
require "active_support/ordered_options"

module SerpCheap
  module Rails
    class Railtie < ::Rails::Railtie
      config.serpcheap = ActiveSupport::OrderedOptions.new

      initializer "serpcheap.configure" do |app|
        SerpCheap::Rails.apply_options(app.config.serpcheap)
      end

      config.after_initialize do
        SerpCheap::Rails.configuration.cache_store ||= ::Rails.cache
      end
    end
  end
end
