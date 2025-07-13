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
      @current_backup_target = nil
    end

    def run!
      logger.reset
      config.backends.each do |backend|
        self.current_backup_target = BackupTarget.new(backend: backend, locations: config.locations)
        ENV["RESTIC_PASSWORD"] = current_backup_target.backend.passkey

        init
        backup
        check
        #diff_latest
      end
      logger.info("Run completed.")
    end

    def init(backup_target = current_backup_target)
      return if File.exist?(File.join(backup_target.backend.path, "config"))

      logger.info("Initializing repository")
      restic_command.init!(backup_target)
    end

    def backup(backup_target = current_backup_target)
      logger.info("Backup starting...")
      restic_command.backup!(backup_target)
      logger.info("Backup complete")
    end

    def check(backup_target = current_backup_target)
      logger.info("Checking backups...")
      restic_command.check!(backup_target)
      logger.info("Check complete")
    end

    def diff_latest(backup_target = current_backup_target)
      logger.info("Computing diff of latest snapshot")
      restic_command.diff_latest!(backup_target)
    end

    private

    attr_accessor :current_backup_target
    attr_reader :logger, :config, :restic_command
  end
end
