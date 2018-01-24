require 'socket'
require 'uri'
require './helpers/server_helper'
require 'pry'

WEB_ROOT = './public'

# Initialize a TCPServer object that listens on localhost:2345 for incoming connections
server = TCPServer.new('localhost', 2345)

# loop indefintely
loop do

  socket = server.accept
  # Read the first line of the request (Request-Line)
  request_line = socket.gets

  # Logs request to console
  STDERR.puts request_line
  path = ServerHelper.requested_file(request_line)

  path = File.join(path, 'index.html') if File.directory?(path)
  # Make sure the file exists and is not a directory before
  # attempting to open it.

  if File.exist?(path) && !File.directory?(path)
    File.open(path, 'rb') do |file|
      # We need to include the Content-Type and Content-Length headers
      # to let the client know the size and type of data
      # contained in the response
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{ServerHelper.content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"
      socket.print "\r\n"

      # Write the contents of the file to the socket
      IO.copy_stream(file, socket)
    end
  else
    message = "File not found\n"

    socket.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n"
    socket.print "\r\n"

    socket.print message
  end

  # Close socket/ terminate connection
  socket.close
end
