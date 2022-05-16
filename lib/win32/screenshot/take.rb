module Win32
  module Screenshot
    # Capture Screenshots on Windows with Ruby
    class Take

      class << self
        # Takes a screenshot of the specified object.
        #
        # @example Take a screenshot of the window with the specified title
        #   Win32::Screenshot::Take.of(:window, :title => "Windows Internet Explorer")
        #
        # @example Take a screenshot of the foreground
        #   Win32::Screenshot::Take.of(:foreground)
        #
        # @example Take a screenshot of the desktop
        #   Win32::Screenshot::Take.of(:desktop)
        #
        # @example Take a screenshot of the window with the specified handle
        #   Win32::Screenshot::Take.of(:window, :hwnd => 123456)
        #
        # @example Take a screenshot of the window's client area (e.g. without title bar) with the specified handle
        #   Win32::Screenshot::Take.of(:window, :hwnd => 123456, :context => :client)
        #
        # @example Take a screenshot of the child window with the specified internal class name
        #   Win32::Screenshot::Take.of(:rautomation, RAutomation::Window.new(:hwnd => 123456).child(:class => "Internet Explorer_Server"))
        #
        # @param [Symbol] what the type of the object to take a screenshot of,
        #   possible values are _:foreground_, _:desktop_ and _:window_.
        # @param [Hash] opts options are optional for specifying _:context_ to take a screenshot.
        #   It is possible to specify as many options as are needed for searching for the unique window.
        #   By default the first window with matching identifiers will be taken screenshot of.
        #   It is possible to use in addition to other options a 0-based _:index_ option to search for other windows if multiple
        #   windows match the specified criteria.
        # @option opts [String, Regexp] :title Title of the window
        # @option opts [String, Regexp] :text Visible text of the window
        # @option opts [String, Fixnum] :hwnd Window handle in decimal format
        # @option opts [String, Fixnum] :pid Window process ID (PID)
        # @option opts [String, Fixnum] :index 0-based index to specify n-th window to take a screenshot of if
        #   all other criteria match
        # @option opts [RAutomation::Window] :rautomation RAutomation::Window object to take a screenshot of. Useful for
        #   taking screenshots of the child windows
        # @return [Image] the {Image} of the specified object
        def of(what, opts = {})
          valid_whats = [:foreground, :desktop, :window]
          raise "It is not possible to take a screenshot of '#{what}', possible values are #{valid_whats.join(", ")}" unless valid_whats.include?(what)

          self.send(what, opts)
        end

        alias_method :new, :of

        private

        def foreground(opts)
          hwnd = BitmapMaker.foreground_window
          BitmapMaker.capture_window(hwnd)
        end

        def desktop(opts)
          hwnd = BitmapMaker.desktop_window
          BitmapMaker.capture_screen(hwnd)
        end

        def window(opts)
          win = opts[:rautomation] || RAutomation::Window.new(opts)
          timeout = Time.now + 10
          until win.active?
            if Time.now >= timeout
              Kernel.warn "[WARN] Failed to set window '#{win.locators.inspect}' into focus for taking the screenshot"
              break
            end
            win.activate
          end
          BitmapMaker.capture_window(win.hwnd)
        end
      end
    end
  end
end
