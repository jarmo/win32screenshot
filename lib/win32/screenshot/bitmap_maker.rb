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

        def capture_all(hwnd, context)
          width, height = dimensions_for(hwnd, context)
          capture_area(hwnd, context, 0, 0, width, height)
        end

        SRCCOPY = 0x00CC0020
        DIB_RGB_COLORS = 0

        def capture_area(hwnd, context, x1, y1, x2, y2)
          hScreenDC = send("#{context}_dc", hwnd)
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

          Image.new(bmFileHeader + bmInfo + lpvpxldata.read_string(bitmap_size), w, h)
        ensure
          lpvpxldata.free
          delete_object(hmemBM)
          delete_dc(hmemDC)
          release_dc(0, hScreenDC)
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
