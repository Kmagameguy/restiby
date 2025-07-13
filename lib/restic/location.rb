module Restic
  class Location
    attr_reader :name, :source, :destinations

    def initialize(name:, properties: {})
      @name = name
      @source = properties[:from]
      @destinations = properties[:to].map(&:to_sym)
    end
  end
end
