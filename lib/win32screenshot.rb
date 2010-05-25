$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
Kernel.warn %q(DEPRECATION: use "require 'win32/screenshot'" instead of "require 'win32screenshot'")
require "win32/screenshot"