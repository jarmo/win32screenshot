require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Win32::Screenshot::Util do
  include SpecHelper

  before :all do
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
    x1, y1, x2, y2 = Win32::Screenshot::Util.dimensions_for(@calc_hwnd)
    x1.should == 0
    y1.should == 0
    x2.should be > 100
    y2.should be > 100
  end
  
  after :all do
    Process.kill 9, @calc
  end
end