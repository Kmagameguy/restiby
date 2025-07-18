# frozen_string_literal: true

module Restiby
  class Configuration
    DEFAULT_CONFIG_FILE = "restiby.yml"

    attr_reader :backends, :notifiers, :exclude_file

    def self.load!
      new
    end

    def initialize
      @config = load_yaml
      @exclude_file = @config.dig(:extras, :exclude_file)
      @all_locations = build_locations(@config.dig(:locations) || {})
      @backends  = build_backends(@config.dig(:backends) || {})
      @notifiers = build_notifiers(@config.dig(:notifiers) || {})
    end

    private

    attr_reader :all_locations

    def build_locations(location_hash)
      location_hash.map do |name, properties|
        Location.new(name:, properties:)
      end
    end

    def build_backends(backends)
      backends.map do |name, properties|
        Backend.new(name:, properties:, all_locations:, exclude_file:)
      end
    end

    def build_notifiers(notifiers)
      notifiers.keys.map do |notifier_name|
        klass_constant = notifier_name.to_s.split("_").map(&:capitalize).join("")
        klass = Object.const_get("Restiby::Notifiers::#{klass_constant}")
        klass.new(webhook_url: notifiers[notifier_name][:webhook_url])
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
