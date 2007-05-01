require File.dirname(__FILE__) + '/test_helper.rb'
require 'RMagick'

# Prereqs for this test:
# * Screen res must be 1280x1024
# * Must be run from a command window with dimensions 150x60 characters and default font
# * Must have a maximised IE open
# * Must have a notepad open (you'll have to adjust the size)
class Win32screenshotTest < Test::Unit::TestCase

  def test_should_capture_foreground
    Win32::Screenshot.foreground do |width, height, bmp|
      assert_equal 1280, width
      assert_equal 720,  height
      assert_image(bmp, 'shell')
    end
  end
  
  def test_should_capture_desktop
    Win32::Screenshot.desktop do |width, height, bmp|
      assert_equal 1280, width
      assert_equal 1024,  height
      assert_image(bmp, 'desktop')
    end
  end

  def test_should_set_foreground_window_by_title
    Win32::Screenshot.window(/Internet Explorer/) do |width, height, bmp|
      assert_equal 1280, width
      assert_equal 971,  height
      assert_image(bmp, 'ie')
    end
  end

  def test_should_capture_small_windows_without_corrupting_image
    Win32::Screenshot.window(/Notepad/) do |width, height, bmp_data|
      assert width > 400, "too narrow #{width}"
      assert height > 400, "too short #{height}"
      assert width < 500, "too wide #{width}"
      assert height < 500, "too tall #{height}"

      assert_image(bmp_data, 'notepad')
    end
  end

  def assert_image(bmp, file=nil)
    File.open("#{file}.bmp", "wb") {|io| io.write(bmp)} unless file.nil?
    assert_equal 'BM',  bmp[0..1]
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob do
      self.format = 'PNG'
    end
    assert_equal "\211PNG",  png[0..3]
    File.open("#{file}.png", "wb") {|io| io.write(png)} unless file.nil?
  end
  
  def test_should_have_version
    assert_equal '0.0.4', Win32::Screenshot::VERSION::STRING
  end
  
  def test_sleep_to_verify_that_segfault_happens_at_exit_not_during_work
#    sleep 10
  end
end
