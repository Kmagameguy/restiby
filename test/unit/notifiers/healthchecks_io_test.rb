# frozen_string_literal: true
 
require "test_helper"

module Restiby
  module Notifiers
    class HealthchecksIoTest < ::Minitest::Test
      describe "HealthchecksIo" do
        before do
          @webhook_url = "https://www.example.com/healthchecks_io"
          @healthchecks_io = HealthchecksIo.new(webhook_url: @webhook_url)
        end

        it "constructs a notifier object with a public interface" do
          assert @healthchecks_io.respond_to?(:notify_success!)
          assert @healthchecks_io.respond_to?(:notify_failure!)
        end

        it "makes a get request when creating a 'success' notification" do
          @healthchecks_io.expects(:get).once
          @healthchecks_io.notify_success!
        end
      end
    end
  end
end