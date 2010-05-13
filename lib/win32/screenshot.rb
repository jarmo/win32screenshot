require 'win32/screenshot/bitmap_grabber'

module Win32
  class Screenshot  
    class << self
      def foreground(&proc)
        hwnd = BitmapGrabber.getForegroundWindow
        BitmapGrabber.capture_hwnd(hwnd, &proc)
      end

      def desktop(&proc)
        hwnd = BitmapGrabber.getDesktopWindow
        BitmapGrabber.capture_hwnd(hwnd, &proc)
      end

      def window(title_query, pause=0.1, &proc)
        hwnd = set_foreground_window(title_query)
        sleep(pause)
        BitmapGrabber.capture_hwnd(hwnd, &proc)
      end

      def set_foreground_window(title_query)
        hwnd = BitmapGrabber.get_hwnd(title_query)
        BitmapGrabber.setForegroundWindow(hwnd)
        hwnd
      end
    end
  end
end
