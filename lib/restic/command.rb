module Restic
  class Command
    include ::Restic::Constants::Commands

    def initialize
      @executable = find_restic_binary
    end

    def init!(backup_target)
      run!(INIT, repo: backup_target.backend.path)
    end

    def backup!(backup_target)
      # TODO: Need to loop over locations and run backup on each
      run!(BACKUP, repo: backup_target.backend.path, source: backup_target.locations)
    end

    def check!(backup_target)
      run!(CHECK, repo: backup_target.backend.path)
    end

    def diff_latest!(backup_target)
      run!(DIFF, repo: backup_target.backend.path)
    end

    private

    attr_reader :executable

    def run!(command, options = {})
      arguments = [ "-v" ]

      options.each do |key, value|
        arguments << "--#{key}" << value.to_s
      end

      cmd = [executable, command] + arguments
      cmd += options[:source] if options[:source]
      cmd = cmd.join(" ")

      system!(cmd)
    end

    def find_restic_binary
      system!("which restic")
    end

    def system!(command)
      stdout, stderr, status = Open3.capture3(command)

      if status.success?
        return stdout.strip
      else
        abort("Error: #{stderr}")
      end
    end
  end
end
