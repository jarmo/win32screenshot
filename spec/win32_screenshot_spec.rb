require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "win32-screenshot" do

  before :all do
    FileUtils.rm Dir.glob("*.bmp")
    FileUtils.rm Dir.glob("*.png")
    @notepad = IO.popen("notepad").pid
    @iexplore = IO.popen(File.join(Dir::PROGRAM_FILES, "Internet Explorer", "iexplore about:blank")).pid
    @calc = IO.popen("calc").pid
    # TODO check if programs are opened
    sleep 5
  end

  it "captures foreground" do
    Win32::Screenshot.foreground do |width, height, bmp|
      check_image(bmp, 'foreground')
      hwnd = Win32::Screenshot.GetForegroundWindow()
      dimensions = Win32::Screenshot.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures desktop" do
    Win32::Screenshot.desktop do |width, height, bmp|
      check_image(bmp, 'desktop')
      hwnd = Win32::Screenshot.GetDesktopWindow()
      dimensions = Win32::Screenshot.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures maximized window by window title" do
    # TODO maximize window programmatically
    Win32::Screenshot.window("Internet Explorer") do |width, height, bmp|
      check_image(bmp, 'iexplore')
      hwnd = Win32::Screenshot.get_hwnd("Internet Explorer")
      dimensions = Win32::Screenshot.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures maximized window by window title as a regexp" do
    # TODO maximize window programmatically
    Win32::Screenshot.window(/calculator/i) do |width, height, bmp|
      check_image(bmp, 'calc')
      hwnd = Win32::Screenshot.get_hwnd(/calculator/i)
      dimensions = Win32::Screenshot.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  it "captures small windows" do
    # TODO resize window programmatically
    Win32::Screenshot.window(/Notepad/) do |width, height, bmp|
      check_image(bmp, 'notepad')
      hwnd = Win32::Screenshot.get_hwnd(/Notepad/)
      dimensions = Win32::Screenshot.dimensions_for(hwnd)
      width.should == dimensions[2]
      height.should == dimensions[3]
    end
  end

  def check_image(bmp, file=nil)
    File.open("#{file}.bmp", "wb") {|io| io.write(bmp)} unless file.nil?
    bmp[0..1].should == 'BM'
    img = Magick::Image.from_blob(bmp)
    png = img[0].to_blob {self.format = 'PNG'}
    png[0..3].should == "\211PNG"
    File.open("#{file}.png", "wb") {|io| io.write(png)} unless file.nil?
  end

  after :all do
    Process.kill 9, @notepad
    Process.kill 9, @iexplore
    Process.kill 9, @calc
  end
end
