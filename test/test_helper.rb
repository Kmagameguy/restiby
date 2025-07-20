require "bundler"
Bundler.require :test

require "fileutils"
require "json"
require "logger"
require "minitest/autorun"
require "minitest/spec"
require "minitest/stub_const"
require "mocha/minitest"
require "net/http"
require "open3"
require "optparse"
require "ostruct"
require "uri"
require "yaml"

require_relative "../lib/restiby"

Bundler.setup(:default, :test)

# Mock RSpec-style context blocks
class ::Minitest::Test
  extend Minitest::Spec::DSL

  class << self
    alias context describe
  end
end


module RestibyTestHelpers
  def stub_configuration
    ::Restiby::Configuration.any_instance.stubs(:root_dir).returns(fixtures_path)
  end

  def stub_restic_binary
    ::Restiby::Command.any_instance.stubs(:find_restic_binary).returns("/usr/bin/restic")
  end

  def fixtures_path
    File.join(File.expand_path("../", __FILE__), "fixtures")
  end
end
