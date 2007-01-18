require File.dirname(__FILE__) + '/test_helper.rb'
require 'rubygems'
require 'RMagick'

# Prereqs for this test:
# * Screen res must be 1280x1024
# * Must be run from a command window with dimensions 150x60 characters and default font
# * Must have a maximised IE open
#
class Win32screenshotTest < Test::Unit::TestCase

  def test_should_capture_foreground
    width, height, bmp = Win32::Screenshot.foreground
    assert_equal 1200, width
    assert_equal 744,  height
    assert_image(bmp)
  end
  
  def test_should_capture_desktop
    width, height, bmp = Win32::Screenshot.desktop
    assert_equal 1280, width
    assert_equal 1024,  height
    assert_image(bmp)
  end

  def test_should_set_foreground_window_by_title
    width, height, bmp = Win32::Screenshot.window(/Internet Explorer/)
    sleep(0.2)
    assert_image(bmp)
    assert_equal 1280, width
    assert_equal 975,  height
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
