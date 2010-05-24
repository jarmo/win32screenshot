require 'win32/screenshot/bitmap_maker'

module Win32
  class Screenshot
    class << self
      def foreground(&proc)
        hwnd = BitmapMaker.foreground_window
        BitmapMaker.capture(hwnd, &proc)
      end

      def desktop(&proc)
        hwnd = BitmapMaker.desktop_window
        BitmapMaker.capture(hwnd, &proc)
      end

      def window(title_query, pause=0.5, &proc)
        hwnd = BitmapMaker.hwnd(title_query)
        raise "window with title '#{title_query}' was not found!" unless hwnd
        hwnd(hwnd, pause, &proc)
      end

      def hwnd(hwnd, pause=0.5, &proc)
        BitmapMaker.prepare_window(hwnd, pause)
        BitmapMaker.capture(hwnd, &proc)
      end
    end

  end
end
