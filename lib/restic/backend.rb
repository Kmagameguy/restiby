module Restic
  class Backend
    attr_reader :name, :type, :path, :passkey

    def initialize(name:, properties: {})
      @name = name
      @type = properties[:type]
      @path = properties[:path]
      @passkey = properties[:passkey]
    end
  end
end
