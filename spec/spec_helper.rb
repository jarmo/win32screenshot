$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'spec'
require 'spec/autorun'
require 'rmagick'

module SpecHelper
  def check_image(bmp, file=nil)
    File.open("#{file}.bmp", "wb") {|io| io.write(bmp)} unless file.nil?
    bmp[0..1].should == 'BM'
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob {self.format = 'PNG'}
    png[0..3].should == "\211PNG"
    File.open("#{file}.png", "wb") {|io| io.write(png)} unless file.nil?
  end

  def wait_for_programs_to_open
    until Win32::Screenshot::BitmapMaker.hwnd(/Internet Explorer/) &&
            Win32::Screenshot::BitmapMaker.hwnd(/Notepad/) &&
            Win32::Screenshot::BitmapMaker.hwnd(/Calculator/)
      sleep 0.1
    end
    # just in case of slow PC
    sleep 10
  end

  def maximize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                                 Win32::Screenshot::BitmapMaker::SW_MAXIMIZE)
    sleep 1
  end

  def minimize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                                 Win32::Screenshot::BitmapMaker::SW_MINIMIZE)
    sleep 1
  end

  def resize title
    Win32::Screenshot::BitmapMaker.set_window_pos(Win32::Screenshot::BitmapMaker.hwnd(title),
                                                    Win32::Screenshot::BitmapMaker::HWND_TOPMOST,
                                                    0, 0, 150, 238,
                                                    Win32::Screenshot::BitmapMaker::SWP_NOMOVE)
    sleep 1
  end
end
