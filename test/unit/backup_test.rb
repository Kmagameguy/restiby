# frozen_string_literal: true

require "test_helper"

module Restiby
  class BackupTest < ::Minitest::Test
    describe "Backup" do
      before { stub_configuration }

      describe ".run!" do
        it "creates a new instance of the Backup class and calls its :run! instance method" do
          Backup.any_instance.expects(:run!).once
          Backup.run!
        end
      end

      describe "#run!" do
        before do
          @backup = Backup.new
          Logger.any_instance.expects(:reset).once
          @backup.expects(:update_restic).once
          @backup.expects(:init).at_least_once
          @backup.expects(:backup).at_least_once
          @backup.expects(:check).at_least_once
          @backup.expects(:forget).at_least_once
          @backup.expects(:diff_latest).at_least_once
          @backup.expects(:notify_success).at_least_once
          Logger.any_instance.expects(:info).with("Run completed.").once
        end

        it "runs the automated backup routine" do
          @backup.send(:config).backends.each do |backend|
            @backup.expects(:update_passkey_in_env).with(backend.passkey).once
          end

          @backup.expects(:update_passkey_in_env).with(nil).at_least_once
          @backup.run!
        end
      end

      describe "#update_restic" do
        it "calls the update command" do
          backup = Backup.new
          logger = backup.send(:logger)
          restic_command = backup.send(:restic_command)

          logger.expects(:info).with("Checking restic version...").once
          restic_command.expects(:update!).once

          backup.update_restic
        end
      end

      describe "#init" do
        context "when the repo already exists" do
          it "does nothing" do
            backup = Backup.new
            backend = backup.send(:config).backends.first
            logger = backup.send(:logger)
            restic_command = backup.send(:restic_command)

            logger.expects(:info).never
            restic_command.expects(:init!).never

            File.stubs(:exist?).returns(true)
            backup.init(backend)
          end
        end

        context "when the repo does not exist" do
          it "creates the repo" do
            backup = Backup.new
            backend = backup.send(:config).backends.first
            logger = backup.send(:logger)
            restic_command = backup.send(:restic_command)

            File.stubs(:exist?).with(File.join(backend.path, "config")).returns(false)
            logger.expects(:info).with("Initializing repository: #{backend.name}").once
            restic_command.expects(:init!).with(backend).once

            backup.init(backend)
          end
        end
      end

      describe "#backup" do
        it "runs the backup command for the given backend" do
          backup = Backup.new
          backend = backup.send(:config).backends.first
          logger = backup.send(:logger)
          restic_command = backup.send(:restic_command)

          logger.expects(:info).with("Backup starting for #{backend.name}...").once
          logger.expects(:info).with("Backup complete").once
          restic_command.expects(:backup!).with(backend).once

          backup.backup(backend)
        end
      end

      describe "#check" do
        it "runs the check command for the given backend" do
          backup = Backup.new
          backend = backup.send(:config).backends.first
          logger = backup.send(:logger)
          restic_command = backup.send(:restic_command)

          logger.expects(:info).with("Checking backups...").once
          logger.expects(:info).with("Check complete").once
          restic_command.expects(:check!).with(backend).once

          backup.check(backend)
        end
      end

      describe "#forget" do
        context "when a backend location has a forget policy" do
          it "forgets snapshots" do
            backup = Backup.new
            backend = backup.send(:config).backends.first
            logger = backup.send(:logger)
            restic_command = backup.send(:restic_command)

            logger.expects(:info).with("Forgetting & pruning snapshots").once
            logger.expects(:info).with("snapshots forgotten!").once
            logger.expects(:info).with("Pruning complete")
            restic_command.expects(:forget!).with(backend).returns("snapshots forgotten!")

            backup.forget(backend)
          end
        end  
        
        context "when a forget policy is not specified for any of the backend locations" do
          it "does nothing" do
            backup = Backup.new
            backend = backup.send(:config).backends.first
            logger = backup.send(:logger)
            restic_command = backup.send(:restic_command)
            backend.locations.each { it.stubs(:forget?).returns(false) }

            logger.expects(:info).never
            restic_command.expects(:forget!).never

            backup.forget(backend)
          end
        end
      end

      describe "#diff_latest" do
        it "checks the difference between the latest repo snapshots" do
          backup = Backup.new
          backend = backup.send(:config).backends.first
          logger = backup.send(:logger)
          restic_command = backup.send(:restic_command)

          logger.expects(:info).with("Computing diff of latest snapshot").once
          logger.expects(:info).with("\nDiff of location documents...\n").once
          restic_command.expects(:diff_latest!).returns("\nDiff of location documents...\n")

          backup.diff_latest(backend)
        end
      end

      describe "#notify_success" do
        it "notifies all the configured services" do
          backup = Backup.new
          notifiers = backup.send(:config).notifiers
          notifiers.each { it.expects(:notify_success!).once }

          backup.notify_success
        end
      end
    end
  end
end