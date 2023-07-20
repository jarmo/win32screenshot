$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'win32/screenshot'
require 'rspec'
require 'fileutils'

module SpecHelper
  def save_and_verify_image(img, file=nil)
    FileUtils.mkdir @temp_dir unless File.exist?(@temp_dir)
    file_name = File.join @temp_dir, "#{file}.bmp"
    img.write file_name
    expect(img.bitmap[0..1]).to eq('BM')
  end

  def resize title
    window = RAutomation::Window.new(title: title)
    window.move(left: 0, top: 0, width: 150, height: 238)
  end
end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.before(:suite) {FileUtils.rm Dir.glob(File.join(File.dirname(__FILE__), "tmp/*"))}
  config.before(:all) {@temp_dir = File.join(File.dirname(__FILE__), 'tmp')}
end
