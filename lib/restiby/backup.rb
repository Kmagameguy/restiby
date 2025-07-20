# frozen_string_literal: true

module Restiby
  class Backup
    include ::Restiby::Concerns::EnvManager

    # Convenience method to just run w/defaults
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
      update_restic
      config.backends.each do |backend|
        self.current_backend = backend
        with_passkey(current_backend.passkey) do
          init
          backup
          check
          forget
          diff_latest
          notify_success
        end
      end
      logger.info("Run completed.")
    end

    def update_restic
      logger.info("Checking restic version...")
      restic_command.update!
    end

    def init(backend = current_backend)
      return if File.exist?(File.join(backend.path, "config"))

      logger.info("Initializing repository: #{backend.name}")
      restic_command.init!(backend)
    end

    def backup(backend = current_backend)
      logger.info("Backup starting for #{backend.name}...")
      restic_command.backup!(backend)
      logger.info("Backup complete")
    end

    def check(backend = current_backend)
      logger.info("Checking backups...")
      restic_command.check!(backend)
      logger.info("Check complete")
    end

    def forget(backend = current_backend)
      return unless backend.locations.any?(&:forget?)

      logger.info("Forgetting & pruning snapshots")
      logger.info(restic_command.forget!(backend))
      logger.info("Pruning complete")
    end

    def diff_latest(backend = current_backend)
      logger.info("Computing diff of latest snapshot")
      logger.info(restic_command.diff_latest!(backend))
    end

    def notify_success
      config.notifiers.each(&:notify_success!)
    end

    private

    attr_accessor :current_backend
    attr_reader :logger, :config, :restic_command
  end
end
