module Restiby
  class Parser
    include ::Restiby::Constants::Commands

    def self.parse!
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "usage: restiby.rb [options]"
        opts.on("-aACTION", "--action=ACTION", "Action to perform") do |action|
          options[:action] = action
        end
      end

      parser.parse!

      case options[:action]
      when BACKUP
        Restiby::Backup.run!
      when CHECK
        # Restiby::Check.run!
      when RESTORE
        # Restiby::Restore.run!
      else
        raise ArgumentError, "Unknown action: #{options[:action]}"
      end 
    end
  end
end