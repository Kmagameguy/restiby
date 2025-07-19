# frozen_string_literal: true

module Restiby
  module Notifiers
    class Discord < Base
      CONTENT_MAX_LENGTH = 2000

      def notify_success!(params = {})
        response = post
        response.body
      end

      def notify_failure!
        # Todo
      end

      protected

      def post
        http.request(request_configuration)
      end

      private

      def request_configuration
        return @request if defined?(@request)

        @request = Net::HTTP::Post.new(uri.path)
        @request["Content-Type"] = "application/json"
        @request.body = payload.to_json
        @request
      end
      
      def payload
        @payload ||= {
          content: "```\n#{log}\n```"
        }
      end

      def http
        return @http if defined?(@http)

        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = uri.scheme == "https"
        @http
      end

      def uri
        @uri ||= URI.parse(webhook_url)
      end

      def log
        content = log_file_content
        content.length > max_payload_length ? content[-max_payload_length..-1] : content
      end
      
      def log_file_content
        File.read(log_file)
      end

      def log_file
        File.join(File.expand_path("../../../..", __FILE__), "log", "restiby.log")
      end

      def max_payload_length
        # Discord limits webhook payloads to 2000 characters.
        # Add buffer for <pre> tag we wrap the log content in
        CONTENT_MAX_LENGTH - 10
      end
    end
  end
end
