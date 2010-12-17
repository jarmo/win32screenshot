$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'rubygems'
require 'rspec'
require 'fileutils'

module SpecHelper
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
  end

  def resize title
    hwnd = RAutomation::Window.new(:title => title).hwnd
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
