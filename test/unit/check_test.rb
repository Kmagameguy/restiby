# frozen_string_literal: true

require "test_helper"

module Restiby
  class CheckTest < ::Minitest::Test
    include RestibyTestHelpers

    describe "Check" do
      before do
        stub_configuration
        stub_restic_binary
      end

      describe ".run!" do
        it "creates a new instance of the Check class and calls its :run! instance method" do
          Restiby::Check.any_instance.expects(:run!).once
          Restiby::Check.run!
        end
      end

      describe "#run!" do
        before do
          @check = Restiby::Check.new
          Restiby::Logger.any_instance.expects(:reset).once
          @check.expects(:update_passkey_in_env).at_least_once  
        end

        context "when execution is successful" do
          before do
            @check.expects(:check).at_least_once
            @check.expects(:unset_passkey).at_least_once
          end

          it "checks the integrity of the configured backend repos" do
            @check.run!
          end
        end

        context "when execution encounters a problem" do
          it "unsets the passkey even if something goes wrong" do
            @check.stubs(:check).raises(StandardError, "Something went wrong!")
            @check.expects(:unset_passkey).at_least_once

            assert_raises(StandardError, "Something went wrong!") do
              @check.run!
            end
          end
        end
      end
    end
  end
end