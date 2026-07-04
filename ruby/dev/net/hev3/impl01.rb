require "socket"
require "resolv"

NAMESERVER = ["127.0.0.1", 5300]
HOST = "localhost"
HTTPS_PORT = 8443
HTTP_PORT = 8080

resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
a_records = resolver.getresources(HOST, Resolv::DNS::Resource::IN::A).map { it.address.to_s }
s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)

sock =
  if ARGV[0] == :https
    sockaddr = Socket.sockaddr_in(HTTPS_PORT, a_records.first)
    s.connect(sockaddr)
    ssl_sock = OpenSSL::SSL::SSLSocket.new(s)
    ssl_sock.hostname = HOST
    ssl_sock.connect
    ssl_sock
  else
    sockaddr = Socket.sockaddr_in(HTTP_PORT, a_records.first)
    s.connect(sockaddr)
    s
  end

request_message = "GET / HTTP/1.1\r\nHost: #{HOST}\r\nConnection: close\r\n\r\n"
sock.write request_message

response_message = sock.read
status_line, *rest = response_message.split("\r\n")
_, body = rest.join("\r\n").split("\r\n\r\n", 2)

puts status_line
puts body

sock.close
