require "openssl"
require "socket"

hostname = "ruby-lang.org"
port = 443

tcp_socket = TCPSocket.new(hostname, port)
ssl_context = OpenSSL::SSL::SSLContext.new
ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
ssl_socket.connect

puts "Connected to #{hostname}:#{port} using #{ssl_socket.ssl_version}"

ssl_socket.close
tcp_socket.close
