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
      hwnd = Win32::Screenshot::BitmapMaker.foreground_window
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures desktop" do
    Win32::Screenshot.desktop do |width, height, bmp|
      check_image(bmp, 'desktop')
      hwnd = Win32::Screenshot::BitmapMaker.desktop_window
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures maximized window by window title" do
    title = "Internet Explorer"
    maximize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'iexplore')
      hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures minimized window by window title as a regexp" do
    title = /calculator/i
    minimize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'calc')
      hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
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
      hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures area of the window" do
    title = /calculator/i
    Win32::Screenshot.window_area(title, 30, 30, 100, 150) do |width, height, bmp|
      check_image(bmp, 'calc_part')
      width.should == 70
      height.should == 120
    end
  end

  it "captures whole window if window size is specified as coordinates" do
    title = /calculator/i
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
    Win32::Screenshot.window_area(title, 0, 0, dimensions[2], dimensions[3]) do |width, height, bmp|
      check_image(bmp, 'calc_part_full_window')
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "doesn't allow to capture area of the window with negative coordinates" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 0, 0, -1, 100) {|width, height, bmp| check_image('calc2')}}.
            should raise_exception("specified coordinates (0, 0, -1, 100) are invalid!")
  end

  it "doesn't allow to capture area of the window if coordinates are the same" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 10, 0, 10, 20) {|width, height, bmp| check_image('calc4')}}.
            should raise_exception("specified coordinates (10, 0, 10, 20) are invalid!")
  end

  it "doesn't allow to capture area of the window if second coordinate is smaller than first one" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 0, 10, 10, 9) {|width, height, bmp| check_image('calc5')}}.
            should raise_exception("specified coordinates (0, 10, 10, 9) are invalid!")
  end

  it "doesn't allow to capture area of the window with too big coordinates" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 0, 0, 10, 10000) {|width, height, bmp| check_image('calc3')}}.
            should raise_exception("specified coordinates (0, 0, 10, 10000) are invalid!")
  end

  it "captures by hwnd" do
    title = /calculator/i
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    Win32::Screenshot.hwnd(hwnd) do |width, height, bmp|
      check_image(bmp, 'calc_hwnd')
      dimensions = Win32::Screenshot::BitmapMaker.dimensions_for(hwnd)
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
