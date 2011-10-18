require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Win32::Screenshot::Take do

  before :all do
    Dir.chdir("c:/program files/Internet Explorer") { IO.popen(".\\iexplore about:blank") }
    IO.popen("calc")
    @iexplore = RAutomation::Window.new(:title => /internet explorer/i).pid
    @calc = RAutomation::Window.new(:title => /calculator/i).pid
  end

  it "captures the foreground" do
    image = Win32::Screenshot::Take.of(:foreground)
    save_and_verify_image(image, 'foreground')
    hwnd = Win32::Screenshot::BitmapMaker.foreground_window
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(hwnd, :window)
  end

  it "captures an area of the foreground" do
    image = Win32::Screenshot::Take.of(:foreground, :area => [30, 30, 100, 150])
    save_and_verify_image(image, 'foreground_area')
    image.width.should == 70
    image.height.should == 120
  end

  it "doesn't allow to capture an area of the foreground with invalid coordinates" do
    expect {Win32::Screenshot::Take.of(:foreground, :area => [0, 0, -1, 100])}.
            to raise_exception("specified coordinates (x1: 0, y1: 0, x2: -1, y2: 100) are invalid - cannot be negative!")
  end

  it "captures the desktop" do
    image = Win32::Screenshot::Take.of(:desktop)
    save_and_verify_image(image, 'desktop')
    hwnd = Win32::Screenshot::BitmapMaker.desktop_window
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(hwnd, :window)
  end

  it "captures an area of the desktop" do
    image = Win32::Screenshot::Take.of(:desktop, :area => [30, 30, 100, 150])
    save_and_verify_image(image, 'desktop_area')
    image.width.should == 70
    image.height.should == 120
  end

  it "doesn't allow to capture an area of the desktop with invalid coordinates" do
    expect {Win32::Screenshot::Take.of(:desktop, :area => [0, 0, -1, 100])}.
            to raise_exception("specified coordinates (x1: 0, y1: 0, x2: -1, y2: 100) are invalid - cannot be negative!")
  end

  it "captures a maximized window" do
    window = RAutomation::Window.new(:pid => @iexplore)
    window.maximize
    image = Win32::Screenshot::Take.of(:window, :pid => @iexplore)
    save_and_verify_image(image, 'iexplore_max')
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a minimized window" do
    window = RAutomation::Window.new(:pid => @calc)
    window.minimize
    image = Win32::Screenshot::Take.of(:window, :pid => @calc)
    save_and_verify_image(image, 'calc_min')
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a small window" do
    title = /Internet Explorer/
    resize(title)
    image = Win32::Screenshot::Take.of(:window, :pid => @iexplore)
    save_and_verify_image(image, 'iexplore_resized')

    # we should get the size of the picture because
    # screenshot doesn't include titlebar and the size
    # varies between different themes and Windows versions
    window = RAutomation::Window.new(:pid => @iexplore)
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a window context of the window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @calc, :context => :window)
    save_and_verify_image(image, 'calc_context_window')
    window = RAutomation::Window.new(:pid => @calc)
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a client context of the window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @calc, :context => :client)
    save_and_verify_image(image, 'calc_context_client')
    window = RAutomation::Window.new(:pid => @calc)
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :client)
  end

  it "captures an area of the window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @calc, :area => [30, 30, 100, 150])
    save_and_verify_image(image, 'calc_area')
    image.width.should == 70
    image.height.should == 120
  end

  it "captures by the RAutomation::Window" do
    window = RAutomation::Window.new(:pid => @calc)
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'calc_rautomation')
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a child windows" do
    window = RAutomation::Window.new(:pid => @iexplore).child(:class => "Internet Explorer_Server")
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'iexplore_child')
    [image.width, image.height].should == Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
  end

  it "captures a whole window if window size is specified as coordinates" do
    window = RAutomation::Window.new(:pid => @calc)
    expected_width, expected_height = Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
    image = Win32::Screenshot::Take.of(:window, :rautomation => window, :area => [0, 0, expected_width, expected_height])
    save_and_verify_image(image, 'calc_area_full_window')
    image.width.should == expected_width
    image.height.should == expected_height
  end

  it "doesn't allow to capture an area of the window with negative coordinates" do
    expect {Win32::Screenshot::Take.of(:window, :pid => @calc, :area => [0, 0, -1, 100])}.
            to raise_exception("specified coordinates (x1: 0, y1: 0, x2: -1, y2: 100) are invalid - cannot be negative!")
  end

  it "doesn't allow to capture an area of the window if coordinates are the same" do
    expect {Win32::Screenshot::Take.of(:window, :pid => @calc, :area => [10, 0, 10, 20])}.
            to raise_exception("specified coordinates (x1: 10, y1: 0, x2: 10, y2: 20) are invalid - cannot be x1 >= x2 or y1 >= y2!")
  end

  it "doesn't allow to capture an area of the window if second coordinate is smaller than first one" do
    expect {Win32::Screenshot::Take.of(:window, :pid => @calc, :area => [0, 10, 10, 9])}.
            to raise_exception("specified coordinates (x1: 0, y1: 10, x2: 10, y2: 9) are invalid - cannot be x1 >= x2 or y1 >= y2!")
  end

  it "doesn't allow to capture an area of the window with too big coordinates" do
    window = RAutomation::Window.new(:pid => @calc)
    expected_width, expected_height = Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
    expect {Win32::Screenshot::Take.of(:window, :pid => @calc, :area => [0, 0, 10, 1000])}.
            to raise_exception("specified coordinates (x1: 0, y1: 0, x2: 10, y2: 1000) are invalid - maximum x2: #{expected_width} and y2: #{expected_height}!")
  end

  after :all do
    [@iexplore, @calc].each do |pid|
      # kill them in a jruby friendly way
      system("taskkill /PID #{pid} > nul")
    end
  end
end
