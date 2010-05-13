require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "win32-screenshot" do

  before :all do
    @notepad = IO.popen("notepad").pid
    @iexplore = IO.popen(File.join(Dir::PROGRAM_FILES, "Internet Explorer", "iexplore")).pid
    # allow for programs to start
    sleep 10
  end

  it "fails" do
    fail "hey buddy, you should probably rename this file and start specing for real"
  end

  after :all do
    Process.kill 9, @notepad rescue nil
    Process.kill 9, @iexplore rescue nil
  end
end
