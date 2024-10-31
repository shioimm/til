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
 * explicitly specify the option +fast_fallback:false+.
 *
 * Happy Eyeballs Version 2 is not provided on Windows,
 * and it behaves the same as in Ruby 3.3 and earlier.
 *
 * [:resolv_timeout] Specifies the timeout in seconds from when the hostname resolution starts.
 * [:connect_timeout] This method sequentially attempts connecting to all candidate destination addresses.<br>The +connect_timeout+ specifies the timeout in seconds from the start of the connection attempt to the last candidate.<br>By default, all connection attempts continue until the timeout occurs.<br>When +fast_fallback:false+ is explicitly specified,<br>a timeout is set for each connection attempt and any connection attempt that exceeds its timeout will be canceled.
 * [:fast_fallback] Enables the Happy Eyeballs Version 2 algorithm (enabled by default).
 *
 * === Happy Eyeballs Version 2
 * Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
 * is an algorithm designed to improve client socket connectivity.<br>
 * It aims for more reliable and efficient connections by performing hostname resolution
 * and connection attempts in parallel, instead of serially.
 *
 * Starting from Ruby 3.4, this method operates as follows with this algorithm except on Windows:
 *
 * 1. Start resolving both IPv6 and IPv4 addresses concurrently.
 * 2. Start connecting to the one of the addresses that are obtained first.<br>If IPv4 addresses are obtained first,
 *    the method waits 50 ms for IPv6 name resolution to prioritize IPv6 connections.
 * 3. After starting a connection attempt, wait 250 ms for the connection to be established.<br>
 *    If no connection is established within this time, a new connection is started every 250 ms<br>
 *    until a connection is  established or there are no more candidate addresses.<br>
 *    (Although RFC 8305 strictly specifies sorting addresses,<br>
 *    this method only alternates between IPv6 / IPv4 addresses due to the performance concerns)
 * 4. Once a connection is established, all remaining connection attempts are canceled.
 */
```
