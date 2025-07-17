Bundler.require
require "rake/testtask"

desc "Default: run tests"
task default: :test

Rake::TestTask.new do |task|
  task.libs    = ["lib", "test"]
  task.pattern = "test/**/*_test.rb"
  task.verbose = true
end
