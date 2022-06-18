# Win32::Screenshot

*   http://github.com/jarmo/win32screenshot


## DESCRIPTION

Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats!

## INSTALL

    gem install win32screenshot

## SYNOPSIS

    require 'win32/screenshot'

    # Take a screenshot of the window with the specified title
    Win32::Screenshot::Take.of(:window, title: "Windows Internet Explorer").write("image.bmp")

    # Take a screenshot of the whole desktop area, including all monitors if multiple are connected
    Win32::Screenshot::Take.of(:desktop).write("image.png")

    # Take a screenshot of the foreground window
    Win32::Screenshot::Take.of(:foreground).write("image.png")

    # Take a screenshot of the foreground window, and writing over previous image if it exists
    Win32::Screenshot::Take.of(:foreground).write!("image.png")

    # Take a screenshot of the specified window with title matching the regular expression
    Win32::Screenshot::Take.of(:window, title: /internet/i).write("image.jpg")

    # Take a screenshot of the window with the specified handle
    Win32::Screenshot::Take.of(:window, hwnd: 123456).write("image.gif")

    # Take a screenshot of the child window with the specified internal class name
    Win32::Screenshot::Take.of(:rautomation, RAutomation::Window.new(hwnd: 123456).
                              child(class: "Internet Explorer_Server")).write("image.png")

    # Use the bitmap blob for something else
    image = Win32::Screenshot::Take.of(:window, hwnd: 123456)
    image.height # => height of the image
    image.width  # => width of the image
    image.bitmap # => bitmap blob

## Copyright

Copyright (c) Jarmo Pertman, Aslak Hellesøy. See LICENSE for details.
