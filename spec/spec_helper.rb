$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'spec'
require 'spec/autorun'
require "win32/process"
require "win32/dir"

Spec::Runner.configure do |config|
end
