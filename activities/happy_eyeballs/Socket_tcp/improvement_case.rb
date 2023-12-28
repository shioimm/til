require 'socket'
# require_relative './socket'

# class Addrinfo
#   class << self
#     def foreach(nodename, service, family=nil, socktype=nil, protocol=nil, flags=nil, timeout: nil, &block)
#       getaddrinfo(nodename, service, Socket::AF_INET6, socktype, protocol, flags, timeout: timeout)
#         .concat(getaddrinfo(nodename, service, Socket::AF_INET, socktype, protocol, flags, timeout: timeout))
#         .each(&block)
#     end
#
#     def getaddrinfo(_, _, family, *_)
#       case family
#       when Socket::AF_INET6 then sleep # [Addrinfo.tcp("::1", port)]
#       when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", 9292)]
#       end
#     end
#   end
# end

fork do
  socket = Socket.new(Socket::AF_INET6, :STREAM)
  socket.setsockopt(:SOCKET, :REUSEADDR, true)
  socket.bind(Socket.pack_sockaddr_in(9292, '::1'))
  sleep 10
  socket.listen(5)
  connection, _ = socket.accept
  connection.close
  socket.close
end

fork do
  socket = Socket.new(Socket::AF_INET, :STREAM)
  socket.setsockopt(:SOCKET, :REUSEADDR, true)
  socket.bind(Socket.pack_sockaddr_in(9292, '127.0.0.1'))
  socket.listen(5)
  connection, _ = socket.accept
  connection.close
  socket.close
end

Socket.tcp("localhost", 9292)
