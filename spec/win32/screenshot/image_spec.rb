require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Win32::Screenshot::Image do

  before :all do
    IO.popen("calc")
    @calc = RAutomation::Window.new(:title => /calculator/i).pid
    @image = Win32::Screenshot::Take.of(:window, :pid => @calc)
  end

  describe "stores raw bitmap data" do
    it "#bitmap" do
      @image.bitmap[0..1].should == 'BM'
    end
  end

  describe "saving the image to the disk" do
    context "saving to the bmp format" do
      it "#write" do
        file_path = @temp_dir + '/image.bmp'
        expect {@image.write(file_path)}.to_not raise_exception
        File.open(file_path, "rb") {|io| io.read}[0..1].should == "BM"
      end
    end

    context "saving to the png format" do
      it "#write" do
        file_path = @temp_dir + '/image.png'
        expect {@image.write(file_path)}.to_not raise_exception
        File.open(file_path, "rb") {|io| io.read}[0..3].should == "\211PNG".force_encoding(Encoding::ASCII_8BIT)
      end
    end

    context "trying to save to the unknown format" do
      it "#write" do
        file_path = @temp_dir + '/image.notknown'
        expect {@image.write(file_path)}.
                to raise_exception("File '#{file_path}' has to have one of the following extensions: #{Win32::Screenshot::Image::FORMATS.join(", ")}")
        File.should_not exist(file_path)
      end
    end

    context "trying to save with the filename without an extension" do
      it "#write" do
        file_path = @temp_dir + '/image'
        expect {@image.write(file_path)}.
                to raise_exception("File '#{file_path}' has to have one of the following extensions: #{Win32::Screenshot::Image::FORMATS.join(", ")}")
        File.should_not exist(file_path)
      end
    end

    context "not allowing to overwrite existing files" do
      it "#write" do
        file_path = @temp_dir + '/invalid-image.png'
        content = "invalid content"
        File.open(file_path, "w") {|io| io.write content}
        expect {@image.write(file_path)}.to raise_exception("File already exists: #{file_path}!")
        File.size(file_path).should == content.size
      end
    end
  end

  after :all do
    # kill in a jruby friendly way
    system("taskkill /PID #{@calc} > nul")
  end

end
