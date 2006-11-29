require File.dirname(__FILE__) + '/test_helper.rb'

class Win32screenshotTest < Test::Unit::TestCase

  def test_should_create_bmp
    width, height, bmp = Win32::Screenshot.foreground
    assert_equal 1280, width
    assert_equal 720,  height
    assert_equal 'BM',  bmp[0..1]
  end
  
  def test_should_be_convertible_to_png
    require 'rubygems'
    require 'RMagick'

    width, height, bmp = Win32::Screenshot.foreground
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob do
      self.format = 'PNG'
    end
    assert_equal "\211PNG",  png[0..3]
  end
end
