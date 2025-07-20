# frozen_string_literal: true

require "test_helper"

module Restiby
  class ConfigurationTest < ::Minitest::Test
    include RestibyTestHelpers

    describe "Configuration" do
      before { stub_configuration }

      describe ".load!" do
        it "reads the yaml file and constructs a Configuration object with a public interface" do
          expected_backends = %i[ localstorage ]
          expected_notifiers = [ ::Restiby::Notifiers::Discord, ::Restiby::Notifiers::HealthchecksIo ].map { |notifier| notifier.name }

          configuration = Configuration.load!

          assert_equal ".restiby.exclude", configuration.exclude_file
          assert configuration.backends.all? { |backend| backend.is_a?(Backend) }
          assert_equal expected_backends.sort, configuration.backends.map(&:name).sort
          assert_equal expected_notifiers.sort, configuration.notifiers.map { |notifier| notifier.class.name }.sort
        end

        it "raises an error if the configuration file cannot be found" do
          File.stubs(:exist?).returns(false)

          assert_raises(StandardError, "Configuration file not found. Did you make a copy of '#{Configuration::DEFAULT_CONFIG_FILE}.example'?") do
            Configuration.load!
          end
        end
      end
    end
  end
end
