Win32::Screenshot::Desktop = Struct.new(:left, :top, :width, :height) do
   def dimensions
      [left, top, width, height]
   end
end