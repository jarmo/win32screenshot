module Win32
  module Screenshot
    # @private
    # This is an internal class for taking the actual screenshots and not part of a public API.
    class BitmapMaker
      class << self
        extend FFI::Library

        ffi_lib 'user32', 'gdi32'
        ffi_convention :stdcall

        # user32.dll
        attach_function :window_dc, :GetWindowDC,
                        [:long], :long
        attach_function :client_dc, :GetDC,
                        [:long], :long
        attach_function :client_rect, :GetClientRect,
                        [:long, :pointer], :bool
        attach_function :window_rect, :GetWindowRect,
                        [:long, :pointer], :bool
        attach_function :foreground_window, :GetForegroundWindow,
                        [], :long
        attach_function :desktop_window, :GetDesktopWindow,
                        [], :long
        attach_function :print_window, :PrintWindow,
                        [:long, :long, :int], :bool
        attach_function :get_system_metrics, :GetSystemMetrics,
                        [:int], :int

        # gdi32.dll
        attach_function :create_compatible_dc, :CreateCompatibleDC,
                        [:long], :long
        attach_function :create_compatible_bitmap, :CreateCompatibleBitmap,
                        [:long, :int, :int], :long
        attach_function :select_object, :SelectObject,
                        [:long, :long], :long
        attach_function :di_bits, :GetDIBits,
                        [:long, :long, :int, :int, :pointer, :pointer, :int], :int
        attach_function :delete_object, :DeleteObject,
                        [:long], :bool
        attach_function :delete_dc, :DeleteDC,
                        [:long], :bool
        attach_function :release_dc, :ReleaseDC,
                        [:long, :long], :int
        attach_function :bit_blt, :BitBlt,
                        [:long, :int, :int, :int, :int, :long, :int, :int, :long], :bool

        DIB_RGB_COLORS = 0
        PW_RENDERFULLCONTENT = 0x00000002
        SRCCOPY = 0x00CC0020

        SM_XVIRTUALSCREEN = 76
        SM_YVIRTUALSCREEN = 77
        SM_CXVIRTUALSCREEN = 78
        SM_CYVIRTUALSCREEN = 79

        def capture_window(hwnd, context)
          width, height = dimensions_for(hwnd, context)

          hScreenDC, hmemDC, hmemBM = prepare_object(hwnd, context, width, height)
          print_window(hwnd, hmemDC, PW_RENDERFULLCONTENT)
          create_bitmap(hScreenDC, hmemDC, hmemBM, width, height)
        end

        def capture_screen(hwnd, context)
          left, top, width, height = desktop.dimensions

          hScreenDC, hmemDC, hmemBM = prepare_object(hwnd, context, width, height)
          bit_blt(hmemDC, 0, 0, width, height, hScreenDC, left, top, SRCCOPY)
          create_bitmap(hScreenDC, hmemDC, hmemBM, width, height)
        end

        def prepare_object(hwnd, context, width, height)
          hScreenDC = send("#{context}_dc", hwnd)
          hmemDC = create_compatible_dc(hScreenDC)
          hmemBM = create_compatible_bitmap(hScreenDC, width, height)
          select_object(hmemDC, hmemBM)
          [hScreenDC, hmemDC, hmemBM]
        end

        def create_bitmap(hScreenDC, hmemDC, hmemBM, width, height)
          bitmap_size = width * height * 3 + width % 4 * height
          lpvpxldata = FFI::MemoryPointer.new(bitmap_size)

          # Bitmap header
          # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
          bmInfo = [40, width, height, 1, 24, 0, 0, 0, 0, 0, 0, 0].pack('L3S2L6')
          di_bits(hmemDC, hmemBM, 0, height, lpvpxldata, bmInfo, DIB_RGB_COLORS)

          bmFileHeader = [
                  19778,
                  bitmap_size + 40 + 14,
                  0,
                  0,
                  54
          ].pack('SLSSL')

          Image.new(bmFileHeader + bmInfo + lpvpxldata.read_string(bitmap_size), width, height)
        ensure
          lpvpxldata.free
          delete_object(hmemBM)
          delete_dc(hmemDC)
          release_dc(0, hScreenDC)
        end

        def desktop
          Win32::Screenshot::Desktop.new(
               get_system_metrics(SM_XVIRTUALSCREEN),
               get_system_metrics(SM_YVIRTUALSCREEN),
               get_system_metrics(SM_CXVIRTUALSCREEN),
               get_system_metrics(SM_CYVIRTUALSCREEN)
          )
        end

        def dimensions_for(hwnd, context)
          rect = [0, 0, 0, 0].pack('l4')
          BitmapMaker.send("#{context}_rect", hwnd.to_i, rect)
          left, top, width, height = rect.unpack('l4')

          if context == :window
            [width + 1 - left, height + 1 - top]
          else
            [width, height]
          end
        end
      end
    end
  end
end
