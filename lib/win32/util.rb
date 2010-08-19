module Win32
  class Screenshot
    class Util
      class << self

        def all_windows
          titles = []
          window_callback = FFI::Function.new(:bool, [ :long, :pointer ], { :convention => :stdcall }) do |hwnd, param|
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
        
        def window_class hwnd
          title = FFI::MemoryPointer.new :char, 100
          BitmapMaker.class_name(hwnd, title, 99)
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
        
        def window_process_id(hwnd)
          BitmapMaker.get_process_id_from_hwnd(hwnd)
        end

      end
    end
  end
end