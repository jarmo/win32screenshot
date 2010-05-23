require 'win32/screenshot/bitmap_grabber'

module Win32
  class Screenshot
    class << self
      def foreground(&proc)
        hwnd = BitmapGrabber.foreground_window
        BitmapGrabber.capture(hwnd, &proc)
      end

      def desktop(&proc)
        hwnd = BitmapGrabber.desktop_window
        BitmapGrabber.capture(hwnd, &proc)
      end

      def window(title_query, pause=0.5, &proc)
        hwnd = BitmapGrabber.hwnd(title_query)
        raise "window with title '#{title_query}' was not found!" unless hwnd
        hwnd(hwnd, pause, &proc)
      end

      def hwnd(hwnd, pause=0.5, &proc)
        BitmapGrabber.prepare_window(hwnd, pause)
        BitmapGrabber.capture(hwnd, &proc)
      end
    end

  end
end
