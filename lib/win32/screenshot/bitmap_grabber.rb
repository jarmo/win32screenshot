require 'windows/window'
require 'windows/gdi/device_context'
require 'windows/gdi/bitmap'
require 'windows/memory'
require 'windows/msvcrt/buffer'
require 'windows/thread'

module Win32
  class Screenshot
    module BitmapGrabber
      include Windows::Window
      include Windows::GDI::DeviceContext
      include Windows::GDI::Bitmap
      include Windows::Memory
      include Windows::Thread
      include Windows::MSVCRT::Buffer

      Windows::API.auto_namespace = self.to_s
      Windows::API.auto_constant  = true
      Windows::API.auto_method    = true
      Windows::API.new('IsWindowVisible', 'L', 'B', 'user32')
      Windows::API.new('IsIconic', 'L', 'B', 'user32')
      Windows::API.new('ShowWindow', 'LI', 'B', 'user32')
      Windows::API.new('SetForegroundWindow', 'L', 'B', 'user32')
      Windows::API.new('SetFocus', 'L', 'B', 'user32')
      Windows::API.new('SetWindowPos', 'LLIIIII', 'B', 'user32')
      Windows::API.new('SwitchToThisWindow', 'LB', 'V', 'user32')

      EnumWindowsProc = Win32::API::Callback.new('LP', 'I') do |hwnd, param|
        title_buffer = Win32::Screenshot::GetWindowTextLength(hwnd) + 1
        title = "\0" * title_buffer
        Win32::Screenshot::GetWindowText(hwnd, title, title_buffer)
        if title =~ Regexp.new(param) && Win32::Screenshot::IsWindowVisible(hwnd)
          @@hwnd = hwnd
          false
        else
          true
        end
      end

      HWND_TOPMOST = -1
      HWND_NOTOPMOST = -2
      SWP_NOSIZE = 1
      SWP_NOMOVE = 2
      SWP_SHOWWINDOW = 40

      def get_hwnd(window_title)
        @@hwnd = nil
        EnumWindows(EnumWindowsProc, window_title.to_s)
        @@hwnd
      end

      def prepare_window(hwnd)
        restore(hwnd) if IsIconic(hwnd)
        set_foreground(hwnd)
      end

      def restore(hwnd)
        ShowWindow(hwnd, SW_RESTORE)
        sleep 0.5
      end

      def set_foreground(hwnd)
        # trying multiple solutions to set
        # window to the foreground
        if GetForegroundWindow() != hwnd
          other_thread = GetWindowThreadProcessId(hwnd, nil)
          current_thread = GetWindowThreadProcessId(GetCurrentThreadId(), nil)
          AttachThreadInput(current_thread, other_thread, true)
          SetForegroundWindow(hwnd)
          SetFocus(hwnd)
          AttachThreadInput(current_thread, other_thread, false)
          sleep 0.1
        end

        if GetForegroundWindow() != hwnd
          SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE)
          SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOMOVE | SWP_NOSIZE)
          sleep 0.1
        end

        if GetForegroundWindow() != hwnd
          SwitchToThisWindow(hwnd, false)
          sleep 0.1
        end
      end

      def dimensions_for(hwnd)
        rect = [0, 0, 0, 0].pack('L4')
        GetClientRect(hwnd, rect)
        x1, y1, x2, y2 = rect.unpack('L4')
      end

      def capture_hwnd(hwnd, &proc)
        hScreenDC = GetDC(hwnd)
        x1, y1, x2, y2 = dimensions_for(hwnd)
        capture(hScreenDC, x1, y1, x2, y2, &proc)
      end

      def capture(hScreenDC, x1, y1, x2, y2, &proc)
        w = x2-x1
        h = y2-y1

        # Reserve some memory
        hmemDC = CreateCompatibleDC(hScreenDC)
        hmemBM = CreateCompatibleBitmap(hScreenDC, w, h)
        SelectObject(hmemDC, hmemBM)
        BitBlt(hmemDC, 0, 0, w, h, hScreenDC, 0, 0, SRCCOPY)
        bitmap_size = w * h * 3 + w % 4 * h
        hpxldata = GlobalAlloc(GMEM_FIXED, bitmap_size)
        lpvpxldata = GlobalLock(hpxldata)

        # Bitmap header
        # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
        bmInfo = [40, w, h, 1, 24, 0, 0, 0, 0, 0, 0, 0].pack('L3S2L6')
        GetDIBits(hmemDC, hmemBM, 0, h, lpvpxldata, bmInfo, DIB_RGB_COLORS)

        bmFileHeader = [
                19778,
                bitmap_size + 40 + 14,
                0,
                0,
                54
        ].pack('SLSSL')

        bitmap = 0.chr * (bitmap_size)
        memcpy(bitmap, lpvpxldata, bitmap_size)
        bmp_data = bmFileHeader + bmInfo + bitmap
        proc.call(w, h, bmp_data)
      ensure
        GlobalUnlock(hpxldata)
        GlobalFree(hpxldata)
        DeleteObject(hmemBM)
        DeleteDC(hmemDC)
        ReleaseDC(0, hScreenDC)
        nil
      end
    end
  end
end