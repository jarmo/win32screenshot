require 'dl/import'
require 'win32/api'

module Win32
  class Screenshot
    module BitmapGrabber
      # win32-api implementations
      EnumWindows = Win32::API.new('EnumWindows', 'KP', 'L', 'user32')
      GetWindowText = Win32::API.new('GetWindowText', 'LPI', 'I', 'user32')
      GetWindowTextLength = Win32::API.new('GetWindowTextLength', 'L', 'I', 'user32')
      EnumWindowsProc = Win32::API::Callback.new('LP', 'I') do |handle, param|
        title_buffer = GetWindowTextLength.call(handle) + 1
        title = "\0" * title_buffer
        GetWindowText.call(handle, title, title_buffer)
        if title =~ @title_matcher ||= Regexp.new(param)
          @@hwnd = handle
          false
        else
          true
        end
      end

      module_function
      # works with regular strings and regexps
      def get_hwnd(window_title)
        @@hwnd = nil
        EnumWindows.call(EnumWindowsProc, window_title.to_s)
        @@hwnd
      end

      GetForegroundWindow = Win32::API.new('GetForegroundWindow', [], 'L', 'user32')

      def getForegroundWindow
        GetForegroundWindow.call
      end

      GetDesktopWindow = Win32::API.new('GetDesktopWindow', [], 'L', 'user32')

      def getDesktopWindow
        GetForegroundWindow.call
      end

      # Ruby::DL
      extend DL::Importable

      dlload "kernel32.dll", "user32.dll", "gdi32.dll"

      SRCCOPY = 0xCC0020
      GMEM_FIXED = 0
      DIB_RGB_COLORS = 0

      typealias "HBITMAP", "unsigned int"
      typealias "LPRECT", "unsigned int*"

      extern "BOOL GetWindowRect(HWND, LPRECT)"
      extern "BOOL GetClientRect(HWND, LPRECT)"
      extern "HDC GetDC(HWND)"
      extern "HDC GetWindowDC(int)"
      extern "HDC CreateCompatibleDC(HDC)"
      extern "int GetDeviceCaps(HDC, int)"
      extern "HBITMAP CreateCompatibleBitmap(HDC, int, int)"
      extern "long SelectObject(HDC, HBITMAP)"
      extern "long BitBlt(HDC, long, long, long, long, HDC, long, long, long)"
      extern "void* GlobalAlloc(long, long)"
      extern "void* GlobalLock(void*)"
      extern "long GetDIBits(HDC, HBITMAP, long, long, void*, void*, long)"
      extern "long GlobalUnlock(void*)"
      extern "long GlobalFree(void*)"
      extern "long DeleteObject(unsigned long)"
      extern "long DeleteDC(HDC)"
      extern "long ReleaseDC(long, HDC)"
      extern "BOOL SetForegroundWindow(HWND)"

      def capture(hScreenDC, x1, y1, x2, y2, &proc)
        raise "You must pass a block of arity 3 (width, height, data)" unless block_given?
        raise "You must pass a block of arity 3 (width, height, data)" unless proc.arity == 3
        w = x2-x1
        h = y2-y1

        # Reserve some memory
        hmemDC = createCompatibleDC(hScreenDC)
        hmemBM = createCompatibleBitmap(hScreenDC, w, h)
        selectObject(hmemDC, hmemBM)
        bitBlt(hmemDC, 0, 0, w, h, hScreenDC, 0, 0, SRCCOPY)
        hpxldata = globalAlloc(GMEM_FIXED, w * h * 3 + w % 4 * h)
        lpvpxldata = globalLock(hpxldata)

        # Bitmap header
        # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
        bmInfo = [40, w, h, 1, 24, 0, 0, 0, 0, 0, 0, 0].pack('LLLSSLLLLLL').to_ptr

        getDIBits(hmemDC, hmemBM, 0, h, lpvpxldata, bmInfo, DIB_RGB_COLORS)

        bmFileHeader = [
                19778,
                w * h * 3 + w % 4 * h + 40 + 14,
                0,
                0,
                54
        ].pack('SLSSL').to_ptr

        bmp_data = bmFileHeader.to_s(14) + bmInfo.to_s(40) + lpvpxldata.to_s(w * h * 3 + w % 4 *h)
        proc.call(w, h, bmp_data)

        globalUnlock(hpxldata)
        globalFree(hpxldata)
        deleteObject(hmemBM)
        deleteDC(hmemDC)
        releaseDC(0, hScreenDC)
        nil
      end

      module_function

      def dimensions_for(hwnd)
        rect = DL.malloc(DL.sizeof('LLLL'))
        getClientRect(hwnd, rect)
        x1, y1, x2, y2 = rect.to_a('LLLL')
        return x1, x2, y1, y2
      end

      module_function

      def capture_hwnd(hwnd, &proc)
        hScreenDC = getDC(hwnd)

        # Find the dimensions of the window
        x1, x2, y1, y2 = dimensions_for(hwnd)

        capture(hScreenDC, x1, y1, x2, y2, &proc)
      end
    end
  end
end