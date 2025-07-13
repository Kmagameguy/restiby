module Restic
  class Backend
    attr_reader :name, :type, :path, :passkey, :locations

    def initialize(name:, properties: {}, locations: {})
      @name = name
      @type = properties[:type]
      @path = properties[:path]
      @passkey = properties[:passkey]
      @locations = extract_locations(locations)
    end

    private

    def extract_locations(locations)
      locations.select do |location|
        location.to_sym == name.to_sym
      end
    end
  end
end
