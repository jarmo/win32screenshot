# coding: utf-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "win32screenshot"
    gem.summary = %Q{Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats!}
    gem.description = %Q{Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats!}
    gem.email = ["jarmo.p@gmail.com", "aslak.hellesoy@gmail.com"]
    gem.homepage = "http://github.com/jarmo/win32screenshot"
    gem.authors = ["Jarmo Pertman", "Aslak Hellesøy"]

    gem.rdoc_options = ["--main", "README.rdoc"]

    gem.add_dependency "ffi", "~>1.0"
    gem.add_dependency "mini_magick", "~>3.2.0"
    gem.add_dependency "rautomation", "~>0.5"

    gem.add_development_dependency "rspec", "~>2.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

desc "Remove all temporary files"
task :clobber => [:clobber_rdoc, :clobber_rcov] do
  rm_r "spec/tmp"
end
