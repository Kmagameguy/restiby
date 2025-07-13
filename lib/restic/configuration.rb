# frozen_string_literal: true

module Restic
  class Configuration
    DEFAULT_CONFIG_FILE = "restic-backup.yml"

    attr_reader :backends

    def self.load!
      new
    end

    def initialize
      @config = load_yaml
      @locations = @config.dig(:locations) || {}
      @backends  = build_backends(@config.dig(:backends) || {})
    end

    private

    attr_reader :locations

    def build_backends(backends)
      backends.map do |name, properties|
        Backend.new(name:, properties:, locations:)
      end
    end

    def load_yaml
      if !File.exist?(configuration_file)
        raise StandardError, "Configuration file not found. Did you make a copy of '#{DEFAULT_CONFIG_FILE}.example'?"
      end

      YAML.load_file(configuration_file, symbolize_names: true)
    end

    def configuration_file
      File.join(root_dir, DEFAULT_CONFIG_FILE)
    end

    def root_dir
      File.expand_path("../../../", __FILE__)
    end

    # This is ugly, but I prefer YAML syntax for the configuration file,
    # and the standard YAML library doesn't allow you to cast the hash to Ostruct...
    def to_ostruct(hash)
      JSON.parse(hash.to_json, object_class: OpenStruct)
    end
  end
end
