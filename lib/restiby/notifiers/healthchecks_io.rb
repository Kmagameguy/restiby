module Restiby
  module Notifiers
    # https://healthchecks.io

    class HealthchecksIo < Base
      def notify_success!(params = {})
        get
      end

      def notify_failure!(params = {})
        # Do nothing; healthchecks will automatically report
        # failure if check-in doesn't occur within grace period.
      end
    end
  end
end