require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'win32screenshot', 'version')

AUTHOR = "Aslak Hellesøy"
EMAIL = "aslak.hellesoy@gmail.com"
DESCRIPTION = "Capture Screenshots on Windows with Ruby"
GEM_NAME = "win32screenshot"
RUBYFORGE_PROJECT = "win32screenshot"
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
RELEASE_TYPES = %w( gem ) # can use: gem, tar, zip


NAME = "win32screenshot"
REV = nil # UNCOMMENT IF REQUIRED: File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Win32screenshot::VERSION::STRING + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "win32screenshot documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/*_test.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.
  
  # == Optional
  #p.changes        - A description of the release's latest changes.
  #p.extra_deps     - An array of rubygem dependencies.
  #p.spec_extras    - A hash of extra values to set in the gemspec.
end
          