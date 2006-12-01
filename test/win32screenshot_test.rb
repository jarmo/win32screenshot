require File.dirname(__FILE__) + '/test_helper.rb'
require 'rubygems'
require 'RMagick'

# Prereqs for this test:
# * Must be run from a command window with dimensions 1600x1200 pixels (160x60 characters, default font)
# * Screen res must be 1600x1200
# * Must have a maximised Firefox open
#
class Win32screenshotTest < Test::Unit::TestCase

  def test_should_capture_foreground
    width, height, bmp = Win32::Screenshot.foreground
    assert_equal 1280, width
    assert_equal 720,  height
    assert_image(bmp, "fg.png")
  end
  
  def test_should_capture_desktop
    width, height, bmp = Win32::Screenshot.desktop
    assert_equal 1600, width
    assert_equal 1200,  height
    assert_image(bmp)
  end

  def Xtest_should_capture_window_by_title
    width, height, bmp = Win32::Screenshot.window(/Firefox/)
#    assert_equal 1600, width
#    assert_equal 1147,  height
    assert_image(bmp, "ff.png")
  end
  

  def assert_image(bmp, file=nil)
    assert_equal 'BM',  bmp[0..1]
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob do
      self.format = 'PNG'
    end
    assert_equal "\211PNG",  png[0..3]
    File.open(file, "wb") {|io| io.write(png)} unless file.nil?
  end
end
