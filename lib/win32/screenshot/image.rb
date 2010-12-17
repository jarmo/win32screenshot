module Win32
  module Screenshot
    # Holds the bitmap data and writes it to the disk
    class Image
      # [String] raw bitmap blob
      attr_reader :bitmap

      # [String] bitmap width
      attr_reader :width

      # [String] bitmap height
      attr_reader :height

      # Supported output formats
      FORMATS = %w{bmp gif jpg png}

      # @private
      def initialize(blob, width, height)
        @bitmap = blob
        @width = width
        @height = height
      end

      # Writes image to the disk.
      # @param [String] file_path writes image to the specified path.
      # @raise [RuntimeError] when _file_path_ already exists.
      # @raise [RuntimeError] when _file_path_ is not with the supported output {FORMATS} extension.
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
