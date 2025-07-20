# frozen_string_literal: true

module Restiby
  class Check
    include ::Restiby::Concerns::EnvManager

    def self.run!
      new.run!
    end

    def initialize(logger: ::Restiby::Logger.new, config: ::Restiby::Configuration.load!, restic_command: ::Restiby::Command.new)
      @logger = logger
      @config = config
      @restic_command = restic_command
      @current_backend = nil
    end

    def run!
      logger.reset
      config.backends.each do |backend|
        self.current_backend = backend
        with_passkey(current_backend.passkey) do
          check
        end
      end
    end

    private

    attr_accessor :current_backend
    attr_reader :logger, :config, :restic_command

    def check(backend = current_backend)
      logger.info("Checking integrity of: #{backend.name}...")
      logger.info(restic_command.check!(backend))
      logger.info("Check complete for: #{backend.name}")
    end
  end
end