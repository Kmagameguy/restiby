# frozen_string_literal: true

require "test_helper"

module Restiby
  class CommandTest < ::Minitest::Test
    describe "Command" do
      before do
        @executable = "/usr/bin/restic"
        Command.any_instance.stubs(:system!).with(Restiby::Constants::Commands::WHICH_RESTIC).returns(@executable)
        @command = Command.new
      end

      it "constructs a new command object and finds the restic binary on the system" do
        assert_equal @executable, @command.send(:executable)
      end

      it "raises an error if an unregistered command is used" do
        assert_raises(ArgumentError, "Unregistered command: NOT_A_COMMAND") do
          @command.send(:run!, command: "NOT_A_COMMAND")
        end
      end

      describe "#update!" do
        it "runs the restic self-update command" do
          @command.stubs(:find_restic_version).returns("0.18.0")
          @command.expects(:system!).with([@executable, Restiby::Constants::Commands::SELF_UPDATE].join(" ")).once
          @command.update!
        end

        it "returns a warning message if the restic version doesn't have the self-update command" do
          @command.stubs(:find_restic_version).returns("0.17.3")
          
          assert_equal "Function only available on restic 0.18.0 and newer...", @command.update!
        end

        it "aborts if the system call returns an error" do
          # Remove stubbing from earlier
          Mocha::Mockery.instance.teardown
          StatusStruct = Struct.new(:status) do |klass|
            def success?
              status == "success"
            end
          end

          Open3.expects(:capture3).returns(["", "an error occurred", StatusStruct.new(status: "failed")])

          @command.expects(:abort).with("Error: an error occurred").once
          @command.send(:system!, *["test"])
        end
      end

      describe "#init!" do
        it "initializes a new repository for the given backend" do
          backend = Backend.new(name: "Home", properties: { path: "/home/my_user"} )
          expected_command = [
            @executable,
            Restiby::Constants::Commands::INIT,
             "-v",
             "--repo", backend.path
          ]
          @command.expects(:system!).with(*expected_command).once

          @command.init!(backend)
        end
      end

      describe "#backup!" do
        it "creates a new restic snapshot for the given backend locations" do
          location1 = Location.new(name: "documents", properties: { from: "/home/my_user/documents", to: ["localstorage"] })
          location2 = Location.new(name: "downloads", properties: { from: "/home/my_user/downloads", to: ["localstorage"] })
          backend = Backend.new(name: "localstorage", properties: { path: "/mnt/storage/" }, all_locations: [ location1, location2 ], exclude_file: ".restiby.exclude")

          # command: BACKUP, options: { repo: backend.path, tag: location.tag, exclude_file: backend.exclude_file}, source: location.source
          expected_command1 = [
            @executable,
            Restiby::Constants::Commands::BACKUP,
            "-v",
            "--repo", backend.path,
            "--tag", location1.tag,
            "--exclude-file", backend.exclude_file,
            location1.source
          ]

          expected_command2 = [
            @executable,
            Restiby::Constants::Commands::BACKUP,
            "-v",
            "--repo", backend.path,
            "--tag", location2.tag,
            "--exclude-file", backend.exclude_file,
            location2.source
          ]

          @command.expects(:system!).with(*expected_command1).once
          @command.expects(:system!).with(*expected_command2).once
          @command.backup!(backend)
        end
      end

      describe "#check!" do
        it "runs the restic integrity check on the given backend repo" do
          backend = Backend.new(name: "home", properties: { path: "/home/my_user" })
          expected_command = [
            @executable,
            Restiby::Constants::Commands::CHECK,
            "-v",
            "--repo", backend.path,
          ]

          @command.expects(:system!).with(*expected_command).once
          @command.check!(backend)
        end
      end

      describe "#diff_latest!" do
        before do
          @location1 = Location.new(name: "documents", properties: { from: "/mnt/storage/documents", to: ["home"] })
          @location2 = Location.new(name: "downloads", properties: { from: "/mnt/storage/downloads", to: ["home"] })
          @backend   = Backend.new(name: "home", properties: { path: "/home/my_user" }, all_locations: [@location1, @location2])
          @expected_snapshot_command =
            [@executable] +
            Restiby::Constants::Commands::JSON_SNAPSHOTS.split +
            ["-v", "--repo", @backend.path]
        end

        context "when there are at least 2 snapshots for the given backend" do
          it "compares and returns the differences the snapshots" do
            location1_parent_snapshot_id = "333333dfefg"
            location1_latest_snapshot_id = "12345ffffffdb"
            location2_parent_snapshot_id = "559394844ff"
            location2_latest_snapshot_id = "99949999994"
            
            expected_location1_diff_command = [
              @executable,
              Restiby::Constants::Commands::DIFF,
              "-v",
              "--repo", @backend.path,
              location1_parent_snapshot_id, location1_latest_snapshot_id
            ]
            expected_location2_diff_command = [
              @executable,
              Restiby::Constants::Commands::DIFF,
              "-v",
              "--repo", @backend.path,
              location2_parent_snapshot_id, location2_latest_snapshot_id
            ]
            expected_diff_message = "\nDiff for documents\ndiff for location 1\n--------\n\nDiff for downloads\ndiff for location 2"
            
            @command.expects(:system!)
              .with(*@expected_snapshot_command)
              .returns([
                {
                  "tags" => ["restiby:location:documents"],
                  "parent" => location1_parent_snapshot_id,
                  "id" => location1_latest_snapshot_id
                },
                {
                  "tags" => ["restiby:location:downloads"],
                  "parent" => location2_parent_snapshot_id,
                  "id" => location2_latest_snapshot_id
                }
              ].to_json)

            @command.expects(:system!).with(*expected_location1_diff_command).returns("diff for location 1")
            @command.expects(:system!).with(*expected_location2_diff_command).returns("diff for location 2")

            result = @command.diff_latest!(@backend)
            assert_equal expected_diff_message, result
          end
        end

        context "when there are less than 2 snapshots for the given backend" do
          it "returns a warning message" do
            expected_response =
              "Location documents needs at least two snapshots to calculate a diff!" +
              "\n" + "--------\n" + "Location downloads needs at least two snapshots to calculate a diff!"

            @command.expects(:system!).with(*@expected_snapshot_command).returns([{}].to_json)

            result = @command.diff_latest!(@backend)
            assert_equal expected_response, result
          end
        end
      end

      describe "#forget!" do
        context "when a forget policy is specified for a backend location" do
          it "forgets snapshots according to the policy" do
            location = Location.new(name: "documents", properties: { from: "/mnt/storage/documents", to: ["home"], forget: { keep_last: 7 }})
            backend = Backend.new(name: "home", properties: { path: "/mnt/storage/backup" }, all_locations: [location])

            expected_forget_command = [
              @executable,
              Restiby::Constants::Commands::FORGET,
              "-v",
              "--repo", backend.path,
              "--keep-last", location.keep_last.to_s,
              "--prune"
            ]

            expected_forget_reply = "forgot 1 snapshot!"

            @command.expects(:system!).with(*expected_forget_command).returns(expected_forget_reply)
            result = @command.forget!(backend)
            assert_equal expected_forget_reply, result
          end
        end

        context "when a forget policy is NOT specified for a backend location" do
          it "does nothing" do
            location = Location.new(name: "documents", properties: { from: "/mnt/storage/documents", to: ["home"] })
            backend  = Backend.new(name: "home", properties: { path: "/mnt/storage/backup" }, all_locations: [location])

            @command.expects(:run!).never
            @command.forget!(backend)
          end
        end
      end

      describe "#restore_latest!" do
        before do
          @location1 = Location.new(name: "documents", properties: { from: "/mnt/storage/documents", to: ["home"] })
          @location2 = Location.new(name: "downloads", properties: { from: "/mnt/storage/downloads", to: ["home"] })
          @backend   = Backend.new(name: "home", properties: { path: "/home/my_user" }, all_locations: [@location1, @location2])
          @expected_snapshot_command =
            [@executable] +
            Restiby::Constants::Commands::JSON_SNAPSHOTS.split +
            ["-v", "--repo", @backend.path]
        end

        it "restores the latest snapshot data for each backend location to the specified directory" do
          location1_latest_snapshot_id = "111111111"
          location2_latest_snapshot_id = "222222222"
          expected_location1_system_command = [
            @executable,
            Restiby::Constants::Commands::RESTORE,
            location1_latest_snapshot_id,
            "-v",
            "--repo", @backend.path,
            "--target", Restiby::Restore::DEFAULT_RESTORE_PATH
          ]
          expected_location2_system_command = [
            @executable,
            Restiby::Constants::Commands::RESTORE,
            location2_latest_snapshot_id,
            "-v",
            "--repo", @backend.path,
            "--target", Restiby::Restore::DEFAULT_RESTORE_PATH
          ]

          @command.expects(:system!)
            .with(*@expected_snapshot_command)
            .returns([
              {
                "tags" => ["restiby:location:documents"],
                "parent" => "",
                "id" => location1_latest_snapshot_id
              },
              {
                "tags" => ["restiby:location:downloads"],
                "parent" => "",
                "id" => location2_latest_snapshot_id
              }
            ].to_json)

          @command.expects(:system!).with(*expected_location1_system_command).once
          @command.expects(:system!).with(*expected_location2_system_command).once
          @command.restore_latest!(backend: @backend)
        end

        it "raises an error if there are no snapshots in the repository" do
          @command.stubs(:latest_snapshots).with(@backend).returns({})

          assert_raises(StandardError, "No snapshots found to restore.") do
            @command.restore_latest!(@backend)
          end
        end
      end
    end
  end
end
