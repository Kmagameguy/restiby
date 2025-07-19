# frozen_string_literal: true

require "test_helper"

module Restiby
  class LoggerTest < ::Minitest::Test
    describe "Logger" do
      before do
        @test_log_file = File.join(File.expand_path("../../", __FILE__), "tmp", "test_log.log")
        Logger.any_instance.stubs(:log_file_path).returns(@test_log_file)
        @logger = Logger.new
      end

      after { File.delete(@test_log_file) if File.exist?(@test_log_file) }

      it "writes to STDOUT" do
        STDOUT.expects(:write).once
        @logger.info("Hello World!")
      end

      it "writes to log file" do
        STDOUT.expects(:write).at_least_once
        @logger.info("This is some text.")

        data = File.read(@test_log_file)
        assert_match(/INFO -- : This is some text./, data)
      end

      it "can reset its log file" do
        STDOUT.expects(:write).at_least_once
        @logger.info("Reset me!")

        data = File.read(@test_log_file)
        assert_match(/INFO -- : Reset me!/, data)

        @logger.reset

        data = File.read(@test_log_file)
        assert_empty data
      end
    end
  end
end
