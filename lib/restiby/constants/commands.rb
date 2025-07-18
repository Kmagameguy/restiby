# frozen_string_literal: true

module Restiby
  module Constants
    module Commands
      BACKUP         = "backup"
      CHECK          = "check"
      DIFF           = "diff"
      FORGET         = "forget"
      INIT           = "init"
      RESTORE        = "restore"
      SELF_UPDATE    = "self-update"
      JSON_SNAPSHOTS = "snapshots --json"
      VERSION        = "version | awk '{print $2}'"
      WHICH_RESTIC   = "which restic"

      # Allowlist of commands
      REGISTERED_COMMANDS = [
        BACKUP,
        CHECK,
        DIFF,
        FORGET,
        INIT,
        SELF_UPDATE,
        JSON_SNAPSHOTS,
        VERSION,
        WHICH_RESTIC
      ].freeze
    end
  end
end
