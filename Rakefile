require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :build => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

desc "Remove all temporary files"
task :clobber do
  rm_r ["spec/tmp", "doc", ".yardoc", "coverage"]
end
