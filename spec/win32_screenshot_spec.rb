require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "win32-screenshot" do
  include SpecHelper

  before :all do
    PROGRAM_FILES = "c:/program files/"
    FileUtils.rm Dir.glob("*.bmp")
    FileUtils.rm Dir.glob("*.png")
    @notepad = IO.popen("notepad").pid
    @iexplore = IO.popen(File.join(PROGRAM_FILES, "Internet Explorer", "iexplore about:blank")).pid
    @calc = IO.popen("calc").pid
    wait_for_programs_to_open
  end

  it "captures foreground" do
    Win32::Screenshot.foreground do |width, height, bmp|
      check_image(bmp, 'foreground')
      hwnd = Win32::Screenshot::BitmapGrabber.foreground_window
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures desktop" do
    Win32::Screenshot.desktop do |width, height, bmp|
      check_image(bmp, 'desktop')
      hwnd = Win32::Screenshot::BitmapGrabber.desktop_window
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures maximized window by window title" do
    title = "Internet Explorer"
    maximize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'iexplore')
      hwnd = Win32::Screenshot::BitmapGrabber.hwnd(title)
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures minimized window by window title as a regexp" do
    title = /calculator/i
    minimize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'calc')
      hwnd = Win32::Screenshot::BitmapGrabber.hwnd(title)
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures small windows" do
    title = /Notepad/
    resize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'notepad')
      # we should get the size of the picture because
      # screenshot doesn't include titlebar and the size
      # varies between different themes and Windows versions
      hwnd = Win32::Screenshot::BitmapGrabber.hwnd(title)
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  after :all do
    Process.kill 9, @notepad
    Process.kill 9, @iexplore
    Process.kill 9, @calc
  end
end
