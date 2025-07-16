module Restiby
  module Notifiers
    class Base
      def initialize(webhook_url:)
        @webhook_url = webhook_url
      end

      def notify_success!(params = {})
        raise NoMethodError, "#{__method__} must be implemented in subclasses."
      end

      def notify_failure!(params = {})
        raise NoMethodError, "#{__method__} must be implemented in subclasses."
      end

      protected

      attr_reader :webhook_url

      def get
        Net::HTTP.get(URI.parse(webhook_url))
      end

      def post(params = {})
        Net::HTTP.post_form(URI.parse(webhook_url), params)
      end
    end
  end
end