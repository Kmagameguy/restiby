module Restiby
  class Command
    include ::Restiby::Constants::Commands

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
        options = {}.tap do |opts|
          opts[:repo] = backend.path
          opts[:tag] = location.tag
          opts[:exclude_file] = backend.exclude_file unless backend.exclude_file.nil?
        end

        run!(command: BACKUP, options: options, source: location.source)
      end
    end

    def check!(backend)
      run!(command: CHECK, options: { repo: backend.path })
    end

    def diff_latest!(backend)
      snapshots = latest_snapshots(backend)

      backend.locations.map do |location|
        latest_snapshot = snapshots[location.tag]
        return "Location #{location.name} needs at least two snapshots to calculate a diff!" if latest_snapshot["parent"].nil?

        snapshots_to_diff = [ latest_snapshot["parent"], latest_snapshot["id"] ]
        diff = run!(command: DIFF, options: { repo: backend.path, snapshots: snapshots_to_diff })

        "\nDiff for #{location.name}\n#{diff}"
      end.join("\n--------\n")
    end

    def forget!(backend)
      backend.locations.map do |location|
        next unless location.forget?

        run!(command: FORGET, options: { repo: backend.path }.merge(location.forget_and_prune_policy))
      end.compact.join("\n---------\n")
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
      snapshots(backend)
        .reject   { !it.keys.include?("tags") }
        .map      { it.slice("parent", "tags", "id") }
        .group_by { it["tags"][0] }
        .transform_values { it.last }
    end

    def snapshots(backend)
      JSON.parse(run!(command: JSON_SNAPSHOTS, options: { repo: backend.path }))
    end

    def run!(command:, options: {}, source: nil)
      raise ArgumentError, "Unregistered command: #{command}" unless valid_command?(command)

      arguments = [ "-v" ]

      options.each do |key, value|
        arguments << "--#{key.to_s.tr("_", "-")}" << value.to_s unless [:snapshots, :prune].include?(key)
      end

      arguments << "--prune" if options[:prune]

      cmd = [executable] + command.to_s.split + arguments
      cmd << source if !source.nil?
      cmd += options[:snapshots] if !options[:snapshots].nil? && !options[:snapshots].empty?

      system!(*cmd)
    end

    def find_restic_binary
      system!(WHICH_RESTIC)
    end

    def system!(*command)
      stdout, stderr, status = Open3.capture3(*command)

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
