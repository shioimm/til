require "socket"
require "ipaddr"

def ipv4_route_to?(dst_address, port: 443)
  return false unless IPAddr.new(dst_address).ipv4?

  socket = UDPSocket.new(Socket::AF_INET)
  socket.connect(dst_address, port)

  src_address = IPAddr.new(socket.local_address.ip_address)
  n = src_address.to_i

  return false if n == 0
  return false if (n & 0xff000000) == 0x7f000000 # 127.0.0.0/8
  return false if (n & 0xffff0000) == 0xa9fe0000 # 169.254.0.0/16

  true
rescue SystemCallError, SocketError, IPAddr::InvalidAddressError
  false
ensure
  socket&.close
end
