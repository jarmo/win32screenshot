Dir[File.join(File.dirname(__FILE__), 'win32screenshot/**/*.rb')].sort.each { |lib| require lib }

require 'rubygems'
require 'dl/import'

module Win32
  module Screenshot
    extend DL::Importable

    dlload "kernel32.dll","user32.dll","gdi32.dll"

    USER32 = DL.dlopen("user32")
    EnumWindows = USER32['EnumWindows', 'IPL']
    GetWindowTextLength = USER32['GetWindowTextLengthA' ,'LI' ]
    GetWindowText = USER32['GetWindowTextA', 'iLsL' ] 

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
    extern "BOOL SetForegroundWindow(HWND)"

    # Callback defined once. It has to be defined only once in order to avoid the error "Too many callbacks"
    FIND_WINDOW_CALLBACK = DL.callback('ILL') do |curr_hwnd, p|
      textLength, a = GetWindowTextLength.call(curr_hwnd)
      captionBuffer = " " * (textLength+1)
      t, textCaption = GetWindowText.call(curr_hwnd, captionBuffer, textLength+1)    
      text = textCaption[1].to_s
      # TODO: this is very ugly. How do we pass title query as a param to this block?
      if text =~ $win32screenshot_title_query
        $win32screenshot_hwnd_ref[0] = curr_hwnd
        0
      else
        1
      end
    end

    module_function
    def capture(hScreenDC, x1, y1, x2, y2)
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

    def capture_hwnd(hwnd)
      hScreenDC = getDC(hwnd)

      # Find the dimensions of the window
      rect = DL.malloc(DL.sizeof('LLLL'))
      getClientRect(hwnd, rect)
      x1, y1, x2, y2 = rect.to_a('LLLL')

      capture(hScreenDC, x1, y1, x2, y2)
    end
  
    module_function
    def foreground
      hwnd = getForegroundWindow
      capture_hwnd(hwnd)
    end

    module_function
    def desktop
      hwnd = getDesktopWindow
      capture_hwnd(hwnd)
    end

    module_function
    def window(title_query, pause=0.1)
      hwnd = set_foreground_window(title_query)
      sleep(pause)
      capture_hwnd(hwnd)
    end

    module_function
    def set_foreground_window(title_query)
      hwnd = get_hwnd(title_query)
      setForegroundWindow(hwnd)
      hwnd
    end
    
    module_function
    def get_hwnd(title_query)
      # TODO: ugly, yes I know, but how do we pass in args and get return values from DL callbacks??
      $win32screenshot_hwnd_ref = []
      $win32screenshot_title_query = title_query
      EnumWindows.call(FIND_WINDOW_CALLBACK, 0)
      hwnd = $win32screenshot_hwnd_ref[0]
      raise "Couldn't find window with title matching #{title_query}" if hwnd.nil?
      hwnd
    end
  end
end
