module Win32
  class Screenshot
    class Util
      class << self

        def all_windows
          titles = []
          window_callback = Proc.new do |hwnd, param|
            titles << [window_title(hwnd), hwnd]
            true
          end

          BitmapMaker.enum_windows(window_callback, nil)
          titles
        end

        def window_title hwnd
          title_length = BitmapMaker.window_text_length(hwnd) + 1
          title = FFI::MemoryPointer.new :char, title_length
          BitmapMaker.window_text(hwnd, title, title_length)
          title.read_string
        end

        def window_hwnd(title_query)
          hwnd = BitmapMaker.hwnd(title_query)
          raise "window with title '#{title_query}' was not found!" unless hwnd
          hwnd
        end

        def dimensions_for(hwnd)
          rect = [0, 0, 0, 0].pack('L4')
          BitmapMaker.client_rect(hwnd, rect)
          _, _, width, height = rect.unpack('L4')
          return width, height
        end

      end
    end
  end
end