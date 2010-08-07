require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "win32-screenshot" do
  include SpecHelper    
  
  before :all do
    @notepad = IO.popen("notepad").pid
    @iexplore = IO.popen("\"c:/program files/Internet Explorer/iexplore\" about:blank").pid
    @calc = IO.popen("calc").pid
    wait_for_programs_to_open
    cleanup
  end

  it "captures foreground" do
    Win32::Screenshot.foreground do |width, height, bmp|
      check_image(bmp, 'foreground')
      hwnd = Win32::Screenshot::BitmapMaker.foreground_window
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures area of the foreground" do
    Win32::Screenshot.foreground_area(30, 30, 100, 150) do |width, height, bmp|
      check_image(bmp, 'foreground_area')
      width.should == 70
      height.should == 120
    end
  end

  it "doesn't allow to capture area of the foreground with invalid coordinates" do
    lambda {Win32::Screenshot.foreground_area(0, 0, -1, 100) {|width, height, bmp| check_image('foreground2')}}.
            should raise_exception("specified coordinates (0, 0, -1, 100) are invalid - cannot be negative!")
  end

  it "captures desktop" do
    Win32::Screenshot.desktop do |width, height, bmp|
      check_image(bmp, 'desktop')
      hwnd = Win32::Screenshot::BitmapMaker.desktop_window
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures area of the desktop" do
    Win32::Screenshot.desktop_area(30, 30, 100, 150) do |width, height, bmp|
      check_image(bmp, 'desktop_area')
      width.should == 70
      height.should == 120
    end
  end

  it "doesn't allow to capture area of the desktop with invalid coordinates" do
    lambda {Win32::Screenshot.desktop_area(0, 0, -1, 100) {|width, height, bmp| check_image('desktop2')}}.
            should raise_exception("specified coordinates (0, 0, -1, 100) are invalid - cannot be negative!")
  end

  it "captures maximized window by window title" do
    title = "Internet Explorer"
    maximize(title)
    Win32::Screenshot.window(title) do |width, height, bmp|
      check_image(bmp, 'iexplore')
      hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
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
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
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
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures area of the window" do
    title = /calculator/i
    Win32::Screenshot.window_area(title, 30, 30, 100, 150) do |width, height, bmp|
      check_image(bmp, 'calc_area')
      width.should == 70
      height.should == 120
    end
  end

  it "captures whole window if window size is specified as coordinates" do
    title = /calculator/i
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
    Win32::Screenshot.window_area(title, 0, 0, dimensions[2], dimensions[3]) do |width, height, bmp|
      check_image(bmp, 'calc_area_full_window')
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "doesn't allow to capture area of the window with negative coordinates" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 0, 0, -1, 100) {|width, height, bmp| check_image('calc2')}}.
            should raise_exception("specified coordinates (0, 0, -1, 100) are invalid - cannot be negative!")
  end

  it "doesn't allow to capture area of the window if coordinates are the same" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 10, 0, 10, 20) {|width, height, bmp| check_image('calc4')}}.
            should raise_exception("specified coordinates (10, 0, 10, 20) are invalid - cannot have x1 > x2 or y1 > y2!")
  end

  it "doesn't allow to capture area of the window if second coordinate is smaller than first one" do
    title = /calculator/i
    lambda {Win32::Screenshot.window_area(title, 0, 10, 10, 9) {|width, height, bmp| check_image('calc5')}}.
            should raise_exception("specified coordinates (0, 10, 10, 9) are invalid - cannot have x1 > x2 or y1 > y2!")
  end

  it "doesn't allow to capture area of the window with too big coordinates" do
    title = /calculator/i
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
    lambda {Win32::Screenshot.window_area(title, 0, 0, 10, 1000) {|width, height, bmp| check_image('calc3')}}.
            should raise_exception("specified coordinates (0, 0, 10, 1000) are invalid - maximum are x2=#{dimensions[2]} and y2=#{dimensions[3]}!")
  end

  it "captures by window with handle" do
    title = /calculator/i
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(title)
    Win32::Screenshot.hwnd(hwnd) do |width, height, bmp|
      check_image(bmp, 'calc_hwnd')
      dimensions = Win32::Screenshot::Util.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures area of the window with handle" do
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(/calculator/i)
    Win32::Screenshot.hwnd_area(hwnd, 30, 30, 100, 150) do |width, height, bmp|
      check_image(bmp, 'calc_hwnd_area')
      width.should == 70
      height.should == 120
    end
  end

  it "doesn't allow to capture area of the window with handle with invalid coordinates" do
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(/calculator/i)
    lambda {Win32::Screenshot.hwnd_area(hwnd, 0, 0, -1, 100) {|width, height, bmp| check_image('desktop2')}}.
            should raise_exception("specified coordinates (0, 0, -1, 100) are invalid - cannot be negative!")
  end
  
  it "captures based on coordinates" do
    hwnd = Win32::Screenshot::BitmapMaker.hwnd(/calculator/i)
    bmp1 = bmp2 = nil
    Win32::Screenshot.hwnd_area(hwnd, 100, 100, 170, 180) do |width, height, bmp|; bmp1 = bmp; end
    Win32::Screenshot.hwnd_area(hwnd, 0, 0, 70, 80) do |width, height, bmp|; bmp2 = bmp; end
    bmp1.length.should == bmp2.length
    bmp1.should_not == bmp2
  end
  
  it "enumerates the available windows" do
    all_titles = Win32::Screenshot::Util.all_windows
    all_titles.length.should be > 1
    all_titles[0].should be_an(Array)
    all_titles[0][0].should be_a(String)
    all_titles[0][1].should be_a(Fixnum)
    
    all_titles.map{|title, hwnd| title}.should include("Calculator")
  end    
  
  it "allows window titles to include regular expressions special characters" do
    lambda {Win32::Screenshot::BitmapMaker.hwnd("Window title *^$?([.")}.should_not raise_exception
  end

  after :all do
    Process.kill 9, @notepad
    Process.kill 9, @iexplore rescue nil # allow for a pre-existing IE to have been used.
    Process.kill 9, @calc
  end
end
