# frozen_string_literal: true

module Restic
  class Backup
    # Convenience method to just run w/defaults
    def self.run!
      new.run!
    end

    def initialize(logger: ::Restic::Logger.new, config: Configuration.load!, restic_command: Command.new)
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
        ENV["RESTIC_PASSWORD"] = current_backend.passkey

        init
        backup
        check
        diff_latest
        notify_success
      end
      logger.info("Run completed.")
    end

    def update_restic
      logger.info("Checking restic version...")
      restic_command.update!
    end

    def init(backend = current_backend)
      return if File.exist?(File.join(backend.path, "config"))

      logger.info("Initializing repository")
      restic_command.init!(backend)
    end

    def backup(backend = current_backend)
      logger.info("Backup starting...")
      restic_command.backup!(backend)
      logger.info("Backup complete")
    end

    def check(backend = current_backend)
      logger.info("Checking backups...")
      restic_command.check!(backend)
      logger.info("Check complete")
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
