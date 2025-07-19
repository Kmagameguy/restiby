# frozen_string_literal: true

require "test_helper"

module Restiby
  module Notifiers
    class DiscordTest < ::Minitest::Test
      MockHTTPOK = Struct.new(:body)

      describe "Discord" do
        before do
          @webhook_url = "https://www.example.com/discord"
          Discord.any_instance.stubs(:post).returns(MockHTTPOK.new(body: "OK"))

          @discord = Discord.new(webhook_url: @webhook_url)
        end

        it "constructs a notifier object with a public interface" do
          Discord.any_instance.stubs(:log).returns("INFO -- : Here's some log content")

          response = @discord.notify_success!
          assert_equal "OK", response
        end

        it "truncates messages that are too long to send through the discord API" do
          discord = Discord.new(webhook_url: @webhook_url)
          max_payload_length = discord.send(:max_payload_length)
          content_over_max_length = "a" * (max_payload_length + 1)
          discord.stubs(:log_file_content).returns(content_over_max_length)

          content = discord.send(:log)
          assert content_over_max_length.length > max_payload_length
          assert_equal max_payload_length, content.length
        end
      end
    end
  end
end