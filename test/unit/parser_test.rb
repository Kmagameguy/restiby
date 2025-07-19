# frozen_string_literal: true

require "test_helper"

module Restiby
  class ParserTest < ::Minitest::Test
    describe "Parser" do
      describe ".parse!" do
        it "calls the #parse! instance method" do
          Parser.any_instance.expects(:parse!).once
          Parser.parse!
        end
      end

      describe "#parse!" do
        it "can run the 'backup' subroutine" do
          OptionParser.any_instance.expects(:parse!).once
          Restiby::Backup.expects(:run!).once

          parser = Parser.new
          parser.instance_variable_set(:@options, { action: "backup" })

          parser.parse!
        end

        it "raises an ArgumentError for unregistered actions" do
          OptionParser.any_instance.expects(:parse!).once

          parser = Parser.new
          parser.instance_variable_set(:@options, { action: "my-cool-action" })

          assert_raises(ArgumentError, "Unknown action: my-cool-action") do
            parser.parse!
          end
        end
      end
    end
  end
end