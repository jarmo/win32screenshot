require 'win32/screenshot/bitmap_maker'

module Win32
  # Captures screenshots with Ruby on Windows
  class Screenshot
    class << self

      # captures foreground
      def foreground(&proc)
        hwnd = BitmapMaker.foreground_window
        BitmapMaker.capture(hwnd, &proc)
      end

      # captures desktop
      def desktop(&proc)
        hwnd = BitmapMaker.desktop_window
        BitmapMaker.capture(hwnd, &proc)
      end

      # captures window with a *title_query* and waits *pause* (by default is 0.5)
      # seconds after trying to set window to the foreground
      def window(title_query, pause=0.5, &proc)
        hwnd = BitmapMaker.hwnd(title_query)
        raise "window with title '#{title_query}' was not found!" unless hwnd
        hwnd(hwnd, pause, &proc)
      end

      # captures by window handle
      def hwnd(hwnd, pause=0.5, &proc)
        BitmapMaker.prepare_window(hwnd, pause)
        BitmapMaker.capture(hwnd, &proc)
      end
    end

  end
end
