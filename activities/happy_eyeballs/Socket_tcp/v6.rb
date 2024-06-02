require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  IPV6_ADRESS_FORMAT = /(?i)(?:(?:[0-9A-F]{1,4}:){7}(?:[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){6}(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){5}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,4}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){4}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,3}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){3}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,2}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){2}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:)[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){1}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|::(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|::(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,6}[0-9A-F]{1,4}|:))(?:%.+)?/
  private_constant :IPV6_ADRESS_FORMAT

  @tcp_fast_fallback = true

  class << self
    attr_accessor :tcp_fast_fallback
  end

  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &block) # :yield: socket
    if (!fast_fallback) || (host && connecting_to_ip_address?(host))
      return tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    end

    if local_host && local_port
      # TODO
    end

    ret = loop do
      # TODO
    end

    if block_given?
      begin
        yield ret
      ensure
        ret.close
      end
    else
      ret
    end
  ensure
    if fast_fallback
      # TODO
    end
  end

  def self.connecting_to_ip_address?(hostname)
    hostname.match?(IPV6_ADRESS_FORMAT) || hostname.match?(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)
  end
  private_class_method :connecting_to_ip_address?

  def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    last_error = nil
    ret = nil

    local_addr_list = nil
    if local_host != nil || local_port != nil
      local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
    end

    Addrinfo.foreach(host, port, nil, :STREAM, timeout: resolv_timeout) {|ai|
      if local_addr_list
        local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
        next unless local_addr
      else
        local_addr = nil
      end
      begin
        sock = local_addr ?
          ai.connect_from(local_addr, timeout: connect_timeout) :
          ai.connect(timeout: connect_timeout)
      rescue SystemCallError
        last_error = $!
        next
      end
      ret = sock
      break
    }
    unless ret
      if last_error
        raise last_error
      else
        raise SocketError, "no appropriate local address"
      end
    end
    if block_given?
      begin
        yield ret
      ensure
        ret.close
      end
    else
      ret
    end
  end
  private_class_method :tcp_without_fast_fallback
end

HOSTNAME = "localhost"
PORT = 9292

# HOSTNAME = "www.ruby-lang.org"
# PORT = 80

# # 名前解決動作確認用 (Connection Attempt Delay以内の遅延)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     sleep 0.25
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # 名前解決動作確認用 (タイムアウト)
# Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

# # 名前解決動作確認用 (例外)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     # NOTE ignoreされる
#     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
#   end
# end

# # 名前解決動作確認用 (複数)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT), Addrinfo.tcp("::1", PORT)]
#   else
#     sleep 0.1
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # local_host / local_port を指定する場合
# class Addrinfo
#   class << self
#     alias _getaddrinfo getaddrinfo
#
#     def getaddrinfo(nodename, service, family, *_)
#       if service == 9292
#         if family == Socket::AF_INET6
#           [Addrinfo.tcp("::1", 9292)]
#         else
#           [Addrinfo.tcp("127.0.0.1", 9292)]
#         end
#       else
#         _getaddrinfo(nodename, service, family)
#       end
#     end
#   end
# end
#
# local_ip = Socket.ip_address_list.detect { |addr| addr.ipv4? && !addr.ipv4_loopback? }.ip_address
#
# Socket.tcp(HOSTNAME, PORT, local_ip, 0) do |socket|
#    socket.write "GET / HTTP/1.0\r\n\r\n"
#    print socket.read
# end
#
Socket.tcp(HOSTNAME, PORT, fast_fallback: false) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
end

Socket.tcp("127.0.0.1", PORT) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
