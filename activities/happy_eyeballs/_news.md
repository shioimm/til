* Happy Eyeballs version 2 (RFC8305), an algorithm that ensures faster and more reliable connections
  by attempting IPv6 and IPv4 concurrently, is used in Socket.tcp and TCPSocket.new.
  To disable it globally, set the environment variable `RUBY_TCP_NO_FAST_FALLBACK=1` or
  call `Socket.tcp_fast_fallback=false`.
  Or to disable it on a per-method basis, use the keyword argument `fast_fallback: false`.
  [[Feature #20108]] [[Feature #20782]]
