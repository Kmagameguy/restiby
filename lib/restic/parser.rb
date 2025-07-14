module Restic
  class Parser
    include ::Restic::Constants::Commands

    def self.parse!
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "usage: restic-backup.rb [options]"
        opts.on("-aACTION", "--action=ACTION", "Action to perform") do |action|
          options[:action] = action
        end
      end

      parser.parse!

      case options[:action]
      when BACKUP
        Restic::Backup.run!
      when CHECK
        # Restic::Check.run!
      when RESTORE
        # Restic::Restore.run!
      else
        raise ArgumentError, "Unknown action: #{options[:action]}"
      end 
    end
  end
end