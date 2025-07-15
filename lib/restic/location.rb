# frozen_string_literal: true

module Restiby
  class Location
    TAG_PREFIX = "restiby:location:"

    attr_reader :name, :source, :destinations, :tag

    def initialize(name:, properties: {})
      @name = name
      @source = properties[:from]
      @destinations = properties[:to].map(&:to_sym)
      @tag = "#{TAG_PREFIX}#{@name.to_s.downcase}"
    end
  end
end
