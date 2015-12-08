require 'ffi'
require 'mini_magick'
require 'rautomation'

require File.dirname(__FILE__) + '/screenshot/version'
require File.dirname(__FILE__) + '/screenshot/take'
require File.dirname(__FILE__) + '/screenshot/image'
require File.dirname(__FILE__) + '/screenshot/bitmap_maker'

# add bundled ImageMagick into path
ENV["PATH"] = "#{File.dirname(__FILE__) + "/../../ext/ImageMagick-6.9.2-8-portable-Q16-x86"};#{ENV["PATH"]}"
