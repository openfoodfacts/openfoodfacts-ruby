require 'bundler/gem_tasks'
require 'rake/testtask'
 
Rake::TestTask.new do |task|
  task.libs << "lib"
  task.libs << "test"
  task.pattern = "test/test_*.rb"
end

task default: :test

desc 'Load gem inside irb console'
task :console do
  require 'irb'
  require 'irb/completion'
  require File.join(__FILE__, '../lib/openfoodfacts')
  ARGV.clear
  IRB.start
end