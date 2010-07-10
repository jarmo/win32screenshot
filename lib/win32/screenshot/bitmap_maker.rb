require 'ffi'

module Win32
  class Screenshot
    # internal methods
    module BitmapMaker #:nodoc:all
      extend FFI::Library

      ffi_lib 'user32', 'gdi32'
      ffi_convention :stdcall

      callback :enum_callback, [:long, :pointer], :bool

      # user32.dll
      attach_function :enum_windows, :EnumWindows,
                      [:enum_callback, :pointer], :long
      attach_function :window_text, :GetWindowTextA,
                      [:long, :pointer, :int], :int
      attach_function :window_text_length, :GetWindowTextLengthA,
                      [:long], :int
      attach_function :window_visible, :IsWindowVisible,
                      [:long], :bool
      attach_function :dc, :GetDC,
                      [:long], :long
      attach_function :client_rect, :GetClientRect,
                      [:long, :pointer], :bool
      attach_function :minimized, :IsIconic,
                      [:long], :bool
      attach_function :show_window, :ShowWindow,
                      [:long, :int], :bool
      attach_function :foreground_window, :GetForegroundWindow,
                      [], :long
      attach_function :desktop_window, :GetDesktopWindow,
                      [], :long
      attach_function :window_thread_process_id, :GetWindowThreadProcessId,
                      [:long, :pointer], :long
      attach_function :attach_thread_input, :AttachThreadInput,
                      [:long, :long, :bool], :bool
      attach_function :set_foreground_window, :SetForegroundWindow,
                      [:long], :bool
      attach_function :bring_window_to_top, :BringWindowToTop, 
                       [:long], :bool                
      attach_function :set_active_window, :SetActiveWindow, 
                       [:long], :long
      

      # gdi32.dll
      attach_function :create_compatible_dc, :CreateCompatibleDC,
                      [:long], :long
      attach_function :create_compatible_bitmap, :CreateCompatibleBitmap,
                      [:long, :int, :int], :long
      attach_function :select_object, :SelectObject,
                      [:long, :long], :long
      attach_function :bit_blt, :BitBlt,
                      [:long, :int, :int, :int, :int, :long, :int, :int, :long], :bool
      attach_function :di_bits, :GetDIBits,
                      [:long, :long, :int, :int, :pointer, :pointer, :int], :int
      attach_function :delete_object, :DeleteObject,
                      [:long], :bool
      attach_function :delete_dc, :DeleteDC,
                      [:long], :bool
      attach_function :release_dc, :ReleaseDC,
                      [:long, :long], :int


      EnumWindowCallback = Proc.new do |hwnd, param|
        searched_window = WindowStruct.new param
        title_length = window_text_length(hwnd) + 1
        title = FFI::MemoryPointer.new :char, title_length
        window_text(hwnd, title, title_length)
        title = title.read_string
        if title =~ Regexp.new(searched_window[:title].read_string) && window_visible(hwnd)
          searched_window[:hwnd] = hwnd
          false
        else
          true
        end
      end

      module_function

      class WindowStruct < FFI::Struct
        layout :title, :pointer,
               :hwnd, :long
      end

      def hwnd(window_title)
        window = WindowStruct.new
        window_title = FFI::MemoryPointer.from_string(window_title.to_s)
        window[:title] = window_title
        enum_windows(EnumWindowCallback, window.to_ptr)
        window[:hwnd] == 0 ? nil : window[:hwnd] 
      end

      def prepare_window(hwnd, pause)
        restore(hwnd) if minimized(hwnd)
        set_foreground(hwnd)
        sleep pause
      end

      SW_RESTORE = 9

      def restore(hwnd)
        show_window(hwnd, SW_RESTORE)
      end

      def set_foreground(hwnd)
        if foreground_window != hwnd
          set_foreground_window(hwnd)
          set_active_window(hwnd)
          bring_window_to_top(hwnd)
          # and just in case...
          foreground_thread = window_thread_process_id(foreground_window, nil)
          other_thread = window_thread_process_id(hwnd, nil)          
          attach_thread_input(foreground_thread, other_thread, true) unless other_thread == foreground_thread
          set_foreground_window(hwnd)
          set_active_window(hwnd)
          bring_window_to_top(hwnd)
          attach_thread_input(foreground_thread, other_thread, false) unless other_thread == foreground_thread
        end
      end

      def dimensions_for(hwnd)
        rect = [0, 0, 0, 0].pack('L4')
        client_rect(hwnd, rect)
        x1, y1, x2, y2 = rect.unpack('L4')
      end

      def capture_all(hwnd, &proc)
        x1, y1, x2, y2 = dimensions_for(hwnd)
        capture_area(hwnd, x1, y1, x2, y2, &proc)
      end

      SRCCOPY = 0x00CC0020
      DIB_RGB_COLORS = 0

      def capture_area(hwnd, x1, y1, x2, y2, &proc)
        hScreenDC = dc(hwnd)
        w = x2-x1
        h = y2-y1

        hmemDC = create_compatible_dc(hScreenDC)
        hmemBM = create_compatible_bitmap(hScreenDC, w, h)
        select_object(hmemDC, hmemBM)
        bit_blt(hmemDC, 0, 0, w, h, hScreenDC, x1, y1, SRCCOPY)
        bitmap_size = w * h * 3 + w % 4 * h
        lpvpxldata = FFI::MemoryPointer.new(bitmap_size)

        # Bitmap header
        # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
        bmInfo = [40, w, h, 1, 24, 0, 0, 0, 0, 0, 0, 0].pack('L3S2L6')
        di_bits(hmemDC, hmemBM, 0, h, lpvpxldata, bmInfo, DIB_RGB_COLORS)

        bmFileHeader = [
                19778,
                bitmap_size + 40 + 14,
                0,
                0,
                54
        ].pack('SLSSL')

        bmp_data = bmFileHeader + bmInfo + lpvpxldata.read_string(bitmap_size)
        proc.call(w, h, bmp_data)
      ensure
        lpvpxldata.free
        delete_object(hmemBM)
        delete_dc(hmemDC)
        release_dc(0, hScreenDC)
      end
    end
  end
end