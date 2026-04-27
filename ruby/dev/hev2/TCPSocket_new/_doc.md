```c
/*
 * call-seq:
 *    TCPSocket.new(remote_host, remote_port, local_host=nil, local_port=nil, resolv_timeout: nil, connect_timeout: nil, fast_fallback: true)
 *
 * Opens a TCP connection to +remote_host+ on +remote_port+.  If +local_host+
 * and +local_port+ are specified, then those parameters are used on the local
 * end to establish the connection.
 *
 * Starting from Ruby 3.4, this method operates according to the
 * Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
 * algorithm by default, except on Windows.
 *
 * To make it behave the same as in Ruby 3.3 and earlier,
 * explicitly specify the option fast_fallback:false.
 * Or, setting Socket.tcp_fast_fallback=false will disable
 * Happy Eyeballs Version 2 not only for this method but for all Socket globally.
 *
 * When using TCPSocket.new on Windows, Happy Eyeballs Version 2 is not provided,
 * and it behaves the same as in Ruby 3.3 and earlier.
 *
 * [:resolv_timeout] Specifies the timeout in seconds from when the hostname resolution starts.
 * [:connect_timeout] This method sequentially attempts connecting to all candidate destination addresses.<br>The +connect_timeout+ specifies the timeout in seconds from the start of the connection attempt to the last candidate.<br>By default, all connection attempts continue until the timeout occurs.<br>When +fast_fallback:false+ is explicitly specified,<br>a timeout is set for each connection attempt and any connection attempt that exceeds its timeout will be canceled.
 * [:fast_fallback] Enables the Happy Eyeballs Version 2 algorithm (enabled by default).
 */
```
