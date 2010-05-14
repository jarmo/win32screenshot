require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "win32-screenshot" do

  before :all do
    @notepad = IO.popen("notepad").pid
    @iexplore = IO.popen(File.join(Dir::PROGRAM_FILES, "Internet Explorer", "iexplore")).pid
    # TODO check if programs are opened
    sleep 10
  end

  it "captures foreground" do
    Win32::Screenshot.foreground do |width, height, bmp|
      hwnd = Win32::Screenshot::BitmapGrabber.getForegroundWindow
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[1]
      height.should == dimensions[3]
      check_image(bmp)
    end
  end

  it "captures desktop" do
    Win32::Screenshot.desktop do |width, height, bmp|
      hwnd = Win32::Screenshot::BitmapGrabber.getDesktopWindow
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[1]
      height.should == dimensions[3]
      check_image(bmp)
    end
  end

  it "captures maximized window by window title" do
    # TODO maximize window programmatically
    pending "not yet possible" do
      Win32::Screenshot.window("Internet Explorer") do |width, height, bmp|
        hwnd = Win32::Screenshot.set_foreground_window("Internet Explorer")
        dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
        width.should == dimensions[1]
        height.should == dimensions[3]
        check_image(bmp)
      end
    end
  end

  it "captures maximized window by window title as a regexp" do
    # TODO maximize window programmatically
    Win32::Screenshot.window(/Internet Explorer/) do |width, height, bmp|
      hwnd = Win32::Screenshot.set_foreground_window(/Internet Explorer/)
      dimensions = Win32::Screenshot::BitmapGrabber.dimensions_for(hwnd)
      width.should == dimensions[1]
      height.should == dimensions[3]
      check_image(bmp)
    end
  end

  it "captures small windows" do
    # TODO resize window programmatically
    Win32::Screenshot.window(/Notepad/) do |width, height, bmp_data|
      check_image(bmp_data, 'notepad')
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
  end
end
