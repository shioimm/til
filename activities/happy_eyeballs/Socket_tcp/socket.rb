# イベントループをベースにする

require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  ADDRESS_FAMILIES = {
    ipv6: Socket::AF_INET6,
    ipv4: Socket::AF_INET
  }.freeze
  private_constant :ADDRESS_FAMILIES

  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    # Happy Eyeballs' states
    # - :start
    # - :v6c
    # - :v4w
    # - :v4c
    # - :v46c
    # - :v46w
    # - :success
    # - :failure
    # - :timeout

    # WIP
    state = :start

    addrinfos = {}
    connected_sockets = []
    connecting_sockets = []

    mutex = Mutex.new
    read_resolved_family, write_resolved_family = IO.pipe
    hostname_resolution_threads = []

    connected_socket = loop do
      case state
      when :start
        # TMP
        hostname_resolution_threads.concat(ADDRESS_FAMILIES.keys.map do |family|
          Thread.new(host, port, family) do |host, port, family|
            resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)

            mutex.synchronize do
              addrinfos[family] = resolved_addrinfos
              write_resolved_family.puts family
            end
          end
        end)#.map(&:join)

        # ipv6_addrinfos = Addrinfo.getaddrinfo(host, port, Socket::AF_INET6, :STREAM)
        # addrinfos[:ipv6] = ipv6_addrinfos
        # state = :v6c

        # ipv4_addrinfos = Addrinfo.getaddrinfo(host, port, Socket::AF_INET, :STREAM)
        # addrinfos[:ipv4] = ipv4_addrinfos
        # state = :v4c # TMP

        resolved_families, _, = IO.select([read_resolved_family], nil, nil, nil)

        resolved_family = read_resolved_families.pop.getbyte

        if resolved_family == :ipv6
          state = :v4c
        elsif  resolved_family == :ipv4
          state = :v6c
        end

        next
      when :v6c
        # TMP
        addrinfo = addrinfos[:ipv6].pop
        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
        socket.connect_nonblock(addrinfo, exception: false)
        connecting_sockets.push socket
        state = :v46w
      when :v4w
        # TODO
      when :v4c
        # TMP
        addrinfo = addrinfos[:ipv4].pop
        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
        socket.connect_nonblock(addrinfo, exception: false)
        connecting_sockets.push socket
        state = :v46w
      when :v46c
        # TODO
      when :v46w
        # TODO
        _, connected_sockets, = IO.select(nil, connecting_sockets, nil, nil)
        connected_socket = connected_sockets.pop
        state = :success
        next
      when :success
        break connected_socket
      when :failure
        raise
      when :timeout
        raise
      end
    end

    if block_given?
      begin
        yield connected_socket
      ensure
        # TODO
        #   アドレス解決スレッドを全てexit
        #   connected_socketをclose
      end
    else
      connected_socket
    end
  ensure
    hostname_resolution_threads.each { |th| th&.exit }
  end
end

# HOSTNAME = "www.google.com"
# PORT = 80
HOSTNAME = "localhost"
PORT = 9292
#
# # # 名前解決動作確認用 (遅延)
# # Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
# #   if family == :PF_INET6
# #     sleep 0.025
# #     [Addrinfo.tcp("::1", PORT)]
# #   else
# #     [Addrinfo.tcp("127.0.0.1", PORT)]
# #   end
# # end
#
# # # 名前解決動作確認用 (タイムアウト)
# # Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }
#
# # 名前解決動作確認用 (例外)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == :PF_INET6
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     # NOTE ignoreされる
#     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
#   end
# end
#
# # # local_host / local_port を指定する場合
# # Socket.tcp(HOSTNAME, PORT, 'localhost', (32768..61000).to_a.sample) do |socket|
# #   p socket.addr
# #   socket.write "GET / HTTP/1.0\r\n\r\n"
# #   print socket.read
# #   socket.close
# # end
#
Socket.tcp(HOSTNAME, PORT) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
  socket.close
end
