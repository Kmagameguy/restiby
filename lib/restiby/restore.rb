# frozen_string_literal: true

module Restiby
  class Restore
    include ::Restiby::Concerns::EnvManager

    DEFAULT_SNAPSHOT_ID  = "latest"
    DEFAULT_RESTORE_PATH = "/tmp/restiby-restore"

    def initialize(logger: ::Restiby::Logger.new, config: ::Restiby::Configuration.load!, restic_command: ::Restiby::Command.new)
      @logger = logger
      @config = config
      @restic_command = restic_command
      @current_backend = nil
    end

    def restore!(snapshot_id:, restore_to: DEFAULT_RESTORE_PATH)
      logger.reset
      if snapshot_id == DEFAULT_SNAPSHOT_ID
        config.backends.each do |backend|
          self.current_backend = backend
          with_passkey(current_backend.passkey) do
            restore_latest(restore_to: restore_to)
          end
        end
      else
        raise ArgumentError, "Restoring from a specific snapshot is not yet supported :("
      end
    end

    private

    def restore_latest(restore_to:)
      logger.info("Restoring latest backup for #{current_backend.name.capitalize}, to: #{restore_to}")
      logger.info(restic_command.restore_latest!(backend: current_backend, restore_path: restore_to))
      logger.info("Finished restoring #{current_backend.name.capitalize} to: #{restore_to}")
    end

    attr_accessor :current_backend
    attr_reader :logger, :config, :restic_command
  end
end
