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
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(hwnd, :window))
  end

  it "captures the desktop" do
    image = Win32::Screenshot::Take.of(:desktop)
    desktop_dimensions = Win32::Screenshot::BitmapMaker::desktop
    save_and_verify_image(image, 'desktop')

    expect([image.width, image.height]).to eq([desktop_dimensions.width, desktop_dimensions.height])
  end

  it "captures a maximized window" do
    window = RAutomation::Window.new(:pid => @iexplore)
    window.maximize
    image = Win32::Screenshot::Take.of(:window, :pid => @iexplore)
    save_and_verify_image(image, 'iexplore_max')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
  end

  it "captures a minimized window" do
    window = RAutomation::Window.new(:pid => @notepad)
    window.minimize
    image = Win32::Screenshot::Take.of(:window, :pid => @notepad)
    save_and_verify_image(image, 'notepad_min')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
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
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
  end

  it "captures a window context of the window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @notepad, :context => :window)
    save_and_verify_image(image, 'notepad_context_window')
    window = RAutomation::Window.new(:pid => @notepad)
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
  end

  it "captures a client context of the window" do
    image = Win32::Screenshot::Take.of(:window, :pid => @notepad, :context => :client)
    save_and_verify_image(image, 'notepad_context_client')
    window = RAutomation::Window.new(:pid => @notepad)
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :client))
  end

  it "captures by the RAutomation::Window" do
    window = RAutomation::Window.new(:pid => @notepad)
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'notepad_rautomation')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
  end

  it "captures a child windows" do
    window = RAutomation::Window.new(:pid => @iexplore).child(:class => "Internet Explorer_Server")
    image = Win32::Screenshot::Take.of(:window, :rautomation => window)
    save_and_verify_image(image, 'iexplore_child')
    expect([image.width, image.height]).to eq(Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window))
  end

  it "captures a whole window if window size is specified as coordinates" do
    window = RAutomation::Window.new(:pid => @notepad)
    expected_width, expected_height = Win32::Screenshot::BitmapMaker.dimensions_for(window.hwnd, :window)
    image = Win32::Screenshot::Take.of(:window, :rautomation => window, :area => [0, 0, expected_width, expected_height])
    save_and_verify_image(image, 'notepad_area_full_window')
    expect(image.width).to eq(expected_width)
    expect(image.height).to eq(expected_height)
  end

  after :all do
    [@iexplore, @notepad].each do |pid|
      # kill them in a jruby friendly way
      system("taskkill /PID #{pid} > nul")
    end
  end
end
