module Restiby
  module Concerns
    module EnvManager
      def with_passkey(passkey)
        begin
          update_passkey_in_env(passkey)
          yield
        ensure
          unset_passkey
        end
      end

      def update_passkey_in_env(passkey)
        ENV["RESTIC_PASSWORD"] = passkey
      end

      def unset_passkey
        update_passkey_in_env(nil)
      end
    end
  end
end