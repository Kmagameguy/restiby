require "bundler"
Bundler.require :test

require "fileutils"
require "json"
require "logger"
require "minitest/autorun"
require "minitest/hooks"
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
require_relative "./minitest_spec"

Bundler.setup(:default, :test)