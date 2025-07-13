module Restic
  class Command
    include ::Restic::Constants::Commands

    def initialize
      @executable = find_restic_binary
    end

    def init!(backend)
      run!(INIT, repo: backend.path)
    end

    def backup!(backend)
      backend.locations.each do |location|
        run!(BACKUP, repo: backend.path, source: location)
      end
    end

    def check!(backend)
      run!(CHECK, repo: backend.path)
    end

    def diff_latest!(backend)
      run!(DIFF, repo: backend.path)
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
