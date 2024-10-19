class Socket < BasicSocket
  # :call-seq:
  #   Socket.tcp(host, port, local_host=nil, local_port=nil, [opts]) {|socket| ... }
  #   Socket.tcp(host, port, local_host=nil, local_port=nil, [opts])
  #
  # creates a new socket object connected to host:port using TCP/IP.
  #
  # Starting from Ruby 3.4, this method operates according to the
  # Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
  # algorithm by default.
  #
  # To make it behave the same as in Ruby 3.3 and earlier,
  # explicitly specify the option +fast_fallback:false+.
  #
  # If local_host:local_port is given,
  # the socket is bound to it.
  #
  # The optional last argument _opts_ is options represented by a hash.
  # _opts_ may have following options:
  #
  # [:resolv_timeout] Specifies the timeout in seconds from when the hostname resolution starts.
  # [:connect_timeout] This method sequentially attempts connecting to all candidate destination addresses.<br>The +connect_timeout+ specifies the timeout in seconds from the start of the connection attempt to the last candidate.<br>By default, all connection attempts continue until the timeout occurs.<br>When +fast_fallback:false+ is explicitly specified,<br>a timeout is set for each connection attempt and any connection attempt that exceeds its timeout will be canceled.
  # [:fast_fallback] Enables the Happy Eyeballs Version 2 algorithm (enabled by default).
  #
  # If a block is given, the block is called with the socket.
  # The value of the block is returned.
  # The socket is closed when this method returns.
  #
  # If no block is given, the socket is returned.
  #
  #   Socket.tcp("www.ruby-lang.org", 80) {|sock|
  #     sock.print "GET / HTTP/1.0\r\nHost: www.ruby-lang.org\r\n\r\n"
  #     sock.close_write
  #     puts sock.read
  #   }
  #
  # === Happy Eyeballs Version 2
  # Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
  # is an algorithm designed to improve client socket connectivity.<br>
  # It aims for more reliable and efficient connections by performing hostname resolution
  # and connection attempts in parallel, instead of serially.
  #
  # Starting from Ruby 3.4, this method operates as follows with this algorithm:
  #
  # 1. Start resolving both IPv6 and IPv4 addresses concurrently.
  # 2. Start connecting to the one of the addresses that are obtained first.<br>If IPv4 addresses are obtained first,
  #    the method waits 50 ms for IPv6 name resolution to prioritize IPv6 connections.
  # 3. After starting a connection attempt, wait 250 ms for the connection to be established.<br>
  #    If no connection is established within this time, a new connection is started every 250 ms<br>
  #    until a connection is  established or there are no more candidate addresses.<br>
  #    (Although RFC 8305 strictly specifies sorting addresses,<br>
  #    this method only alternates between IPv6 / IPv4 addresses due to the performance concerns)
  # 4. Once a connection is established, all remaining connection attempts are canceled.
  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket
    # ...
  end
end
