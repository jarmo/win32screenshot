require 'win32/screenshot/bitmap_grabber'

module Win32
  class Screenshot
    extend BitmapGrabber

    class << self
      def foreground(&proc)
        hwnd = GetForegroundWindow()
        capture_hwnd(hwnd, &proc)
      end

      def desktop(&proc)
        hwnd = GetDesktopWindow()
        capture_hwnd(hwnd, &proc)
      end

      def window(title_query, pause=0.1, &proc)
        hwnd = get_hwnd(title_query)
        raise "window with title '#{title_query}' was not found!" unless hwnd
        prepare_window(hwnd, pause)
        capture_hwnd(hwnd, &proc)
      end
    end

  end
end
