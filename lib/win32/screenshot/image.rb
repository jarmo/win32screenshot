module Win32
  class Screenshot
    class Image
      attr_reader :bitmap

      def initialize(bmp_data)
        @bitmap = bmp_data
      end

      def write(file_path)
        raise "File already exists: #{file_path}!" if File.exists? file_path
        ext = File.extname(file_path)[1..-1]
        raise "Please specify '#{file_path}' with an extension to detect the desired image output format!" unless ext

        image = ::MiniMagick::Image.read @bitmap
        image.format ext
        image.write file_path
      end
    end
  end
end
