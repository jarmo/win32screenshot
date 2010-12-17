module RAutomation
  module Adapter
    module Ffi
      # @private
      module Functions
        class << self
          alias_method :child_hwnd, :control_hwnd
        end
      end
    end
  end
end