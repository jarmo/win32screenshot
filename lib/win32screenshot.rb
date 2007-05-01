require 'win32screenshot/bitmap_grabber'
require 'win32screenshot/version'

module Win32
  class Screenshot
    def foreground(&proc)
      hwnd = getForegroundWindow
      capture_hwnd(hwnd, &proc)
    end

    def desktop(&proc)
      hwnd = getDesktopWindow
      capture_hwnd(hwnd, &proc)
    end

    def window(title_query, pause=0.1, &proc)
      hwnd = set_foreground_window(title_query)
      sleep(pause)
      capture_hwnd(hwnd, &proc)
    end

    def set_foreground_window(title_query)
      hwnd = get_hwnd(title_query)
      setForegroundWindow(hwnd)
      hwnd
    end
    
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
