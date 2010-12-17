module RAutomation
  module Adapter
    module Ffi
      # Extensions for RAutomation Ffi adapter
      class Window

        # Searches for the child window of the current window
        # @param {Window} locators locators for the child window
        # @return {Window} child window object
        def child(locators)
          self.class.new :hwnd => Functions.child_hwnd(hwnd, locators)
        end

      end
    end
  end
end