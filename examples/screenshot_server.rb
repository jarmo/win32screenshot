require 'md5'
require 'socket'
require File.dirname(__FILE__) + '/../lib/win32screenshot'

# Simple HTTP server serving screenshots from /foreground and /desktop
port = ARGV[0].nil? ? 2020 : ARGV[0].to_i
server = TCPServer.new('0.0.0.0', port)
while (session = server.accept)
  request = session.gets.strip
  resource = (request.gsub /^GET \/(.*) HTTP.*/, "\\1")
  w, h, bmp = Win32::Screenshot.__send__(resource.to_sym)
  session.print "HTTP/1.1 200/OK\r\n"
  session.print "Content-type: image/bmp\r\n\r\n"
  session.print bmp
  session.close
end
