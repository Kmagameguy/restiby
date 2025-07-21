module Restiby
  class Parser
    include ::Restiby::Constants::Commands

    def self.parse!
      new.parse!
    end

    def initialize
      @options = {}
    end

    def parse!
      input.parse!

      case options[:action]
      when BACKUP
        Restiby::Backup.run!
      when CHECK
        Restiby::Check.run!
      when RESTORE
        snapshot_id = options[:snapshot_id] || Restiby::Restore::DEFAULT_SNAPSHOT_ID
        restore_to  = options[:restore_to]  || Restiby::Restore::DEFAULT_RESTORE_PATH
        Restiby::Restore.new.restore!(snapshot_id:, restore_to:)
      else
        raise ArgumentError, "Unknown action: #{options[:action]}"
      end
    end

    private

    attr_accessor :options

    def input
      OptionParser.new do |opts|
        opts.banner = "usage: restiby.rb [options]"
        opts.on("-aACTION", "--action=ACTION", "Action to perform") do |action|
          options[:action] = action&.downcase&.strip
        end

        opts.on("--snapshot SNAPSHOT_ID", "Only valid for --action restore") do |snapshot_id|
          options[:snapshot_id] = snapshot_id
        end

        opts.on("--restore-to PATH", "Only valid for --action restore") do |path|
          options[:restore_to] = path
        end
      end
    end
  end
end