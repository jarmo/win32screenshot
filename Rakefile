# coding: utf-8

require 'rubygems'
require 'rake'
require 'os'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "win32screenshot"
    gem.summary = %Q{Capture Screenshots on Windows with Ruby}
    gem.description = %Q{Capture Screenshots on Windows with Ruby}
    gem.email = ["jarmo.p@gmail.com", "aslak.hellesoy@gmail.com"]
    gem.homepage = "http://github.com/jarmo/win32screenshot"
    gem.authors = ["Jarmo Pertman", "Aslak Hellesøy"]

    gem.rdoc_options = ["--main", "README.rdoc"]

    gem.add_dependency "ffi", "~>0"

    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency 'os'
    if OS.java?
      gem.add_development_dependency "rmagick4j"
    else
      gem.add_development_dependency "rmagick"
    end
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

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Win32::Screenshot #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Remove all temporary files"
task :clobber => [:clobber_rdoc, :clobber_rcov] do
  rm_r "spec/tmp"
end