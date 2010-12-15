module Win32
  class Screenshot
    class Image
      attr_reader :bitmap

      FORMATS = %w{bmp gif jpg png}

      def initialize(bmp_data)
        @bitmap = bmp_data
      end

      def write(file_path)
        raise "File already exists: #{file_path}!" if File.exists? file_path
        ext = File.extname(file_path)[1..-1]
        raise "File '#{file_path}' has to have one of the following extensions: #{FORMATS.join(", ")}" unless ext && FORMATS.include?(ext.downcase)

        if ext.downcase == "bmp"
          File.open(file_path, "wb") {|io| io.write @bitmap}
        else
          image = ::MiniMagick::Image.read @bitmap
          image.format ext
          image.write file_path
        end
      end
    end
  end
end
