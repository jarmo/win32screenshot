require 'ffi'
require 'mini_magick'
require 'rautomation'

require File.dirname(__FILE__) + '/screenshot/version'
require File.dirname(__FILE__) + '/screenshot/take'
require File.dirname(__FILE__) + '/screenshot/image'
require File.dirname(__FILE__) + '/screenshot/bitmap_maker'
require File.dirname(__FILE__) + '/screenshot/desktop'

# add bundled ImageMagick into path
ENV["PATH"] = "#{File.dirname(__FILE__) + "/../../ext/ImageMagick-7.0.9-8-portable-Q16-x86"};#{ENV["PATH"]}"
