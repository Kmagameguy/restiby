# frozen_string_literal: true

module Restic
  class Logger
    DEFAULT_LOG_NAME = "restic-backup.log"

    def initialize
      @logger = ::Logger.new(MultiIO.new(STDOUT, log_file))
    end

    def info(args)
      @logger.info(args)
    end

    def reset
      File.truncate(log_file, 0)
    end

    private

    def log_file
      File.open(log_file_path, "a")
    end

    def log_file_path
      File.join(root_dir, "log", DEFAULT_LOG_NAME)
    end

    def root_dir
      File.expand_path("../../..", __FILE__)
    end
  end
end
