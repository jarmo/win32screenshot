$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'rubygems'
require 'rspec'
require 'fileutils'

module SpecHelper
  SW_MAXIMIZE = 3
  SW_MINIMIZE = 6
  HWND_TOPMOST = -1
  HWND_NOTOPMOST = -2
  SWP_NOSIZE = 1
  SWP_NOMOVE = 2
  SWP_SHOWWINDOW = 40

  extend FFI::Library
  ffi_lib 'user32'
  ffi_convention :stdcall

  # user32.dll
  attach_function :set_window_pos, :SetWindowPos,
                  [:long, :long, :int, :int, :int, :int, :int], :bool
  
  def save_and_verify_image(img, file=nil)
    FileUtils.mkdir @temp_dir unless File.exists?(@temp_dir)
    file_name = File.join @temp_dir, "#{file}.bmp"
    img.write file_name
    img.bitmap[0..1].should == 'BM'
    saved_image = File.open(file_name, "rb") {|io| io.read}
    saved_image[0..1].should == 'BM'
=begin
img = Magick::Image.from_blob(img)
    png = img[0].to_blob {self.format = 'PNG'}
    png[0..3].should == "\211PNG"
    File.open(File.join(temp_dir, "#{file}.png"), "wb") {|io| io.puts(png)} if file
=end
  end

  def wait_for_programs_to_open
    until Win32::Screenshot::BitmapMaker.hwnd(/Internet Explorer/) &&
            Win32::Screenshot::BitmapMaker.hwnd(/Notepad/)
      sleep 0.1
    end
    wait_for_calculator_to_open

    # just in case of slow PC
    sleep 8
  end

  def wait_for_calculator_to_open
    until Win32::Screenshot::BitmapMaker.hwnd(/Calculator/)
      sleep 0.1
    end
    # just in case of slow PC
    sleep 2
  end

  def maximize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                               SW_MAXIMIZE)
    sleep 1
  end

  def minimize title
    Win32::Screenshot::BitmapMaker.show_window(Win32::Screenshot::BitmapMaker.hwnd(title),
                                               SW_MINIMIZE)
    sleep 1
  end

  def resize title
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    set_window_pos(hwnd,
                   HWND_TOPMOST,
                   0, 0, 150, 238,
                   SWP_NOMOVE)
    set_window_pos(hwnd,
                   HWND_NOTOPMOST,
                   0, 0, 0, 0,
                   SWP_SHOWWINDOW | SWP_NOMOVE | SWP_NOSIZE)
    sleep 1
  end
end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.before(:suite) {FileUtils.rm Dir.glob(File.join(File.dirname(__FILE__), "tmp/*"))}
  config.before(:all) {@temp_dir = File.join(File.dirname(__FILE__), 'tmp')}
end
