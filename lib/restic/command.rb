module Restic
  class Command
    include ::Restic::Constants::Commands

    def initialize
      @executable = find_restic_binary
    end

    def update!
      return "Function only available on restic 0.18.0 and newer..." if restic_version < Gem::Version.new("0.18.0")

      cmd = [executable, SELF_UPDATE].join(" ")
      system!(cmd)
    end

    def init!(backend)
      run!(command: INIT, options: { repo: backend.path })
    end

    def backup!(backend)
      backend.locations.each do |location|
        run!(command: BACKUP, options: { repo: backend.path }, source: location.source)
      end
    end

    def check!(backend)
      run!(command: CHECK, options: { repo: backend.path })
    end

    def diff_latest!(backend)
      snapshots = latest_snapshots(backend)
      return "Repository needs at least two snapshots to run this command..." if snapshots.count < 2

      run!(command: DIFF, options: { repo: backend.path, snapshots: snapshots })
    end

    private

    attr_reader :executable

    def restic_version
      @restic_version ||= Gem::Version.new(find_restic_version)
    end

    def find_restic_version
      cmd = [executable, VERSION].join(" ")
      system!(cmd)
    end

    def latest_snapshots(backend)
      JSON
        .parse(run!(command: JSON_SNAPSHOTS, options: { repo: backend.path }))
        .last(2)
        .map { |snapshot| snapshot["id"]}
    end

    def run!(command:, options: {}, source: nil)
      raise ArgumentError, "Unregistered command: #{command}" unless valid_command?(command)

      arguments = [ "-v" ]

      options.each do |key, value|
        arguments << "--#{key}" << value.to_s unless key == :snapshots
      end

      cmd = [executable, command] + arguments
      cmd << source if !source.nil?
      cmd << options[:snapshots][0] << options[:snapshots][1] if !options[:snapshots].nil?
      cmd = cmd.join(" ")

      system!(cmd)
    end

    def find_restic_binary
      system!(WHICH_RESTIC)
    end

    def system!(command)
      stdout, stderr, status = Open3.capture3(command)

      if status.success?
        return stdout.strip
      else
        abort("Error: #{stderr}")
      end
    end

    def valid_command?(command)
      REGISTERED_COMMANDS.include?(command)
    end
  end
end
