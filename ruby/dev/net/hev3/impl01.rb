require "socket"
require "resolv"

NAMESERVER = ["127.0.0.1", 5300]
HOST = "localhost"
HTTPS_PORT = 8443
HTTP_PORT = 8080

resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
a_records = resolver.getresources(HOST, Resolv::DNS::Resource::IN::A).map { it.address.to_s }

socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)

port = ARGV[0] == :https ? HTTPS_PORT : HTTP_PORT
sockaddr = Socket.sockaddr_in(port, a_records.first)
socket.connect_nonblock(sockaddr, exception: false)

connecting_sockets = []
connecting_sockets.push socket

_, writable_sockets, _ = IO.select(
  nil,
  connecting_sockets,
  nil,
  nil,
)

while (writable_socket = writable_sockets.pop)
  is_connected = (
    sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
    sockopt.int.zero?
  )

  if is_connected
    connecting_sockets.delete writable_socket

    if ARGV[0] == :https
      ssl_socket = OpenSSL::SSL::SSLSocket.new(writable_socket)
      ssl_socket.hostname = HOST
      ssl_socket.connect
      ssl_socket
      connected_socket = ssl_socket
    else
      connected_socket = writable_socket
    end

    break
  end
end

request_message = "GET / HTTP/1.1\r\nHost: #{HOST}\r\nConnection: close\r\n\r\n"
connected_socket.write request_message

response_message = connected_socket.read
status_line, *rest = response_message.split("\r\n")
_, body = rest.join("\r\n").split("\r\n\r\n", 2)

puts status_line
puts body

connected_socket.close
