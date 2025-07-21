# frozen_string_literal: true

require "test_helper"

module Restiby
  class RestoreTest < ::Minitest::Test
    include RestibyTestHelpers

    describe "Restore" do
      before do
        stub_configuration
        stub_restic_binary
      end

      context "when the snapshot ID is 'latest'" do
        before do
          @restore = Restiby::Restore.new
          Restiby::Logger.any_instance.expects(:reset).once
        end

        it "restores the latest snapshots for the given backend's locations" do
          backend = @restore.send(:config).backends.first
          logger = @restore.send(:logger)
          restic_command = @restore.send(:restic_command)
          logger.expects(:info).at_least_once
          restic_command.expects(:restore_latest!).with(backend: backend, restore_path: Restiby::Restore::DEFAULT_RESTORE_PATH).once

          @restore.restore!(snapshot_id: Restiby::Restore::DEFAULT_SNAPSHOT_ID)
        end
      end

      context "when the snapshot ID is a specific SHA" do
        before do
          @restore = Restiby::Restore.new
          Restiby::Logger.any_instance.expects(:reset).once
        end

        it "does nothing yet" do
          assert_raises(ArgumentError, "Restoring from a specific snapshot is not yet supported :(") do
            @restore.restore!(snapshot_id: "123456")
          end
        end
      end
    end
  end
end
