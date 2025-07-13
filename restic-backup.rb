# frozen_string_literal: true

require "fileutils"
require "json"
require "logger"
require "open3"
require "ostruct"
require "yaml"
require_relative "lib/restic/constants/commands"
require_relative "lib/restic/multi_io"
require_relative "lib/restic/logger"
require_relative "lib/restic/location"
require_relative "lib/restic/backend"
require_relative "lib/restic/configuration"
require_relative "lib/restic/command"
require_relative "lib/restic/backup"

Restic::Backup.run!
