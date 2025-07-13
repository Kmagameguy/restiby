module Restic
  class Command
    include ::Restic::Constants::Commands

    def initialize
      @executable = find_restic_binary
    end

    def init!(backend)
      run!(command: INIT, options: { repo: backend.path })
    end

    def backup!(backend)
      backend.locations.each do |location|
        run!(command: BACKUP, options: { repo: backend.path }, source: location)
      end
    end

    def check!(backend)
      run!(command: CHECK, options: { repo: backend.path })
    end

    def diff_latest!(backend)
      snapshots = get_latest_snapshots(backend)
      return "Repository needs at least two snapshots to run this command..." if snapshots.count < 2

      run!(command: DIFF, options: { repo: backend.path, snapshots: snapshots })
    end

    private

    attr_reader :executable

    def get_latest_snapshots(backend)
      JSON
        .parse(run!(command: "snapshots --json", options: { repo: backend.path }))
        .last(2)
        .map { |snapshot| snapshot["id"]}
    end

    def run!(command:, options: {}, source: nil)
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
