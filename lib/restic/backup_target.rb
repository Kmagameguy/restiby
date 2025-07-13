module Restic
  class BackupTarget
    attr_reader :backend, :locations

    def initialize(backend:, locations:)
      @backend = backend
      @locations = parse_locations(locations)
    end

    private

    def parse_locations(locations)
      locations.select { it.name == backend.name }
    end
  end
end
