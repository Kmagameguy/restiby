module Restic
  class Backend
    attr_reader :name, :type, :path, :passkey, :locations, :exclude_file

    def initialize(name:, properties: {}, all_locations: {}, exclude_file: nil)
      @name = name
      @type = properties[:type]
      @path = properties[:path]
      @passkey = properties[:passkey]
      @locations = extract_locations(all_locations)
      @exclude_file = exclude_file
    end

    private

    def extract_locations(all_locations)
      all_locations.select { |location| location.destinations.include?(name) }
    end
  end
end
