require 'ffi'
require 'mini_magick'
require 'rautomation'

require File.dirname(__FILE__) + '/screenshot/version'
require File.dirname(__FILE__) + '/screenshot/take'
require File.dirname(__FILE__) + '/screenshot/image'
require File.dirname(__FILE__) + '/screenshot/bitmap_maker'

# environment variables for bundled MiniMagick
ENV["PATH"] = "#{File.dirname(__FILE__) + "/../../ext"};#{ENV["PATH"]}"
ENV["MAGICK_CODER_MODULE_PATH"] = File.dirname(__FILE__) + "/../../ext/modules/coders"
