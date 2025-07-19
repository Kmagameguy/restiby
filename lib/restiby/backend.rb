module Restiby
  class Backend
    attr_reader :name, :type, :path, :passkey, :locations, :exclude_file

    def initialize(name:, properties: {}, all_locations: {}, exclude_file: nil)
      @name = name.to_sym
      @type = properties[:type]
      @path = properties[:path]
      @passkey = properties[:passkey]
      @locations = extract_locations(all_locations)
      @exclude_file = exclude_file
    end

    private

    def extract_locations(all_locations)
      Array(all_locations).select { |location| location.destinations.include?(name) }
    end
  end
end
