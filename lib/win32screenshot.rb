Dir[File.join(File.dirname(__FILE__), 'win32screenshot/**/*.rb')].sort.each { |lib| require lib }

require 'rubygems'
require 'dl/import'

module Win32
  module Screenshot
    extend DL::Importable

    dlload "kernel32.dll","user32.dll","gdi32.dll"

    SRCCOPY = 0xCC0020
    GMEM_FIXED = 0
    DIB_RGB_COLORS = 0

    typealias "HBITMAP","unsigned int"
    typealias "LPRECT","unsigned int*"

    extern "HWND GetForegroundWindow()"
    extern "HWND GetDesktopWindow()"
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

    module_function
    def capture(hwnd)
      hScreenDC = getDC(hwnd)

      # Find the dimensions of the window
      rect = DL.malloc(DL.sizeof('LLLL'))
      getClientRect(hwnd, rect)
      x1, y1, x2, y2 = rect.to_a('LLLL')
      w = x2-x1
      h = y2-y1

      # Reserve some memory
      hmemDC = createCompatibleDC(hScreenDC)
      hmemBM = createCompatibleBitmap(hScreenDC, w, h)
      selectObject(hmemDC, hmemBM)
      bitBlt(hmemDC, 0, 0, w, h, hScreenDC, 0, 0, SRCCOPY)
      hpxldata = globalAlloc(GMEM_FIXED, w * h * 3)
      lpvpxldata = globalLock(hpxldata)

      # Bitmap header
      # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
      bmInfo = [40, w, h, 1, 24, 0, 0, 0, 0, 0, 0, 0].pack('LLLSSLLLLLL').to_ptr

      getDIBits(hmemDC, hmemBM, 0, h, lpvpxldata, bmInfo, DIB_RGB_COLORS)

      bmFileHeader = [
        19778, 
        (w * h * 3) + 40 + 14,
        0, 
        0, 
        54
      ].pack('SLSSL').to_ptr

      data = bmFileHeader.to_s(14) + bmInfo.to_s(40) + lpvpxldata.to_s(w * h * 3)

      globalUnlock(hpxldata)
      globalFree(hpxldata)
      deleteObject(hmemBM)
      deleteDC(hmemDC)
      releaseDC(0, hScreenDC)
 
      return [w, h, data]
    end
  
    module_function
    def foreground
      capture(getForegroundWindow())
    end

    module_function
    def desktop
      capture(getDesktopWindow())
    end
    
  end
end
