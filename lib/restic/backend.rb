module Restic
  class Backend
    attr_reader :name, :type, :path, :passkey, :locations

    def initialize(name:, properties: {}, all_locations: {})
      @name = name
      @type = properties[:type]
      @path = properties[:path]
      @passkey = properties[:passkey]
      @locations = extract_locations(all_locations)
    end

    private

    def extract_locations(all_locations)
      all_locations.select { |location| location.destinations.include?(name) }
    end
  end
end
