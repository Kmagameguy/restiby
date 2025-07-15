module Restiby
  module Notifiers
    class Discord < Base
      def notify_success!(params = {})
        payload = {
          content: "```\n#{log}\n```"
        }

        uri = URI.parse(webhook_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request.body = payload.to_json

        response = http.request(request)
        response.body
      end

      def notify_failure!
        # Todo
      end

      private

      def log
        log_file = File.join(File.expand_path("../../../..", __FILE__), "log", "restiby.log")
        content = File.read(log_file)
        # Discord limits webhook payloads to 2000 characters.
        # Need to truncate a bit more than that so we can insert the <pre> markdown formatting.
        content.length > 1990 ? content[-1990..-1] : content
      end
    end
  end
end
