require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Win32::Screenshot::Util do
  include SpecHelper

  before :all do
    # should not have any running calculators yet...
    proc {Win32::Screenshot::Util.window_hwnd("Calculator") }.should raise_exception("window with title 'Calculator' was not found!")
    @calc = IO.popen("calc").pid
    wait_for_calculator_to_open
    @calc_hwnd = Win32::Screenshot::Util.window_hwnd("Calculator")
  end

  it ".all_windows enumerates all available windows" do
    all_windows = Win32::Screenshot::Util.all_windows
    all_windows.should_not be_empty
    all_windows[0].should be_an(Array)
    all_windows[0][0].should be_a(String)
    all_windows[0][1].should be_a(Fixnum)

    calculator = all_windows.find {|title, hwnd| title =~ /Calculator/}
    calculator.should_not be_nil
    calculator[0].should == "Calculator"
    calculator[1].should == @calc_hwnd
  end

  it ".window_title returns title of a specified window's handle" do
    Win32::Screenshot::Util.window_title(@calc_hwnd).should == "Calculator"
  end

  it ".dimensions_for window handle returns dimensions of the window in pixels" do
    width, height = Win32::Screenshot::Util.dimensions_for(@calc_hwnd)
    width.should be > 100
    height.should be > 100
  end
  
  after :all do
    # test our hwnd -> pid method
    calc_pid = Win32::Screenshot::Util.window_process_id(@calc_hwnd)
    system("taskkill /PID #{calc_pid}")
    proc {Win32::Screenshot::Util.window_hwnd("Calculator") }.should raise_exception("window with title 'Calculator' was not found!")
  end
end