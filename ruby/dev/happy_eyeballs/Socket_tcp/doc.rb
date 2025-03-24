class Socket < BasicSocket
  # :call-seq:
  #   Socket.tcp(host, port, local_host=nil, local_port=nil, [opts]) {|socket| ... }
  #   Socket.tcp(host, port, local_host=nil, local_port=nil, [opts])
  #
  # Creates a new socket object connected to host:port using TCP/IP.
  #
  # Starting from Ruby 3.4, this method operates according to the
  # Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
  # algorithm by default, except on Windows.
  #
  # For details on Happy Eyeballs Version 2, please refer to the documentation of
  # {Socket.tcp_fast_fallback=}[rdoc-ref:Socket#tcp_fast_fallback=].
  #
  # To make it behave the same as in Ruby 3.3 and earlier,
  # explicitly specify the option fast_fallback:false.
  # Or, setting Socket.tcp_fast_fallback=false will disable
  # Happy Eyeballs Version 2 not only for this method but for all Socket globally.
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
  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket
    # ...
  end
end
