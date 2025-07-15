# frozen_string_literal: true

module Restiby
  class Location
    TAG_PREFIX = "restiby:location:"

    attr_reader :name,
                :source,
                :destinations,
                :tag,
                :keep_last,
                :keep_daily,
                :keep_weekly,
                :keep_monthly,
                :keep_yearly

    def initialize(name:, properties: {})
      @name = name
      @source = properties[:from]
      @destinations = properties[:to].map(&:to_sym)
      @tag = "#{TAG_PREFIX}#{@name.to_s.downcase}"
      @keep_last    = properties.dig(:forget, :keep_last)
      @keep_daily   = properties.dig(:forget, :keep_daily)
      @keep_weekly  = properties.dig(:forget, :keep_weekly)
      @keep_monthly = properties.dig(:forget, :keep_monthly)
      @keep_yearly  = properties.dig(:forget, :keep_yearly)
    end

    def forget?
      forget_policy.any?
    end

    def forget_and_prune_policy
      return {} unless forget?

      forget_policy.merge(prune: true)
    end

    def forget_policy
      {
        keep_last: keep_last,
        keep_daily: keep_daily,
        keep_weekly: keep_weekly,
        keep_monthly: keep_monthly,
        keep_yearly: keep_yearly
      }.compact
    end
  end
end
