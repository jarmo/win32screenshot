require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Win32::Screenshot::Take do

  before :all do
    Dir.chdir("c:/program files/Internet Explorer") { IO.popen(".\\iexplore about:blank") }
    IO.popen("notepad")
    @iexplore = RAutomation::Window.new(:title => /internet explorer/i).pid
    @notepad = RAutomation::Window.new(:title => /notepad/i).pid
  end

  it "captures the foreground" do
    image = Win32::Screenshot::Take.of(:foreground)
    save_and_verify_image(image, 'foreground')
    hwnd = Win32::Screenshot::BitmapMaker.foreground_window
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(hwnd))
  end

  it "captures the desktop" do
    image = Win32::Screenshot::Take.of(:desktop)
    desktop_dimensions = Win32::Screenshot::BitmapMaker::desktop
    save_and_verify_image(image, 'desktop')

    expect([image.width, image.height]).to eq([desktop_dimensions.width, desktop_dimensions.height])
  end

  it "captures a window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @notepad)
    save_and_verify_image(image, 'notepad_context_window')
    window = RAutomation::Window.new(:pid => @notepad)
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
  end

  it "captures a maximized window" do
    window = RAutomation::Window.new(:pid => @iexplore)
    window.maximize
    image = Win32::Screenshot::Take.of(:window, :pid => @iexplore)
    save_and_verify_image(image, 'iexplore_max')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
  end

  it "captures a minimized window" do
    window = RAutomation::Window.new(:pid => @notepad)
    window.minimize
    image = Win32::Screenshot::Take.of(:window, :pid => @notepad)
    save_and_verify_image(image, 'notepad_min')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
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
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
  end

  it "captures by the RAutomation::Window" do
    window = RAutomation::Window.new(:pid => @notepad)
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'notepad_rautomation')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
  end

  it "captures a child window" do
    window = RAutomation::Window.new(:pid => @iexplore).child(:class => "Internet Explorer_Server")
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'iexplore_child')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd))
  end

  after :all do
    [@iexplore, @notepad].each do |pid|
      # kill them in a jruby friendly way
      system("taskkill /PID #{pid} > nul")
    end
  end
end
