```c
/*
 * call-seq:
 *   Socket.tcp_fast_fallback -> true or false
 *
 * Returns whether Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305]),
 * which is provided starting from Ruby 3.4 when using TCPSocket.new and Socket.tcp,
 * is enabled or disabled.
 *
 * If true, it is enabled for TCPSocket.new and Socket.tcp.
 * (Note: Happy Eyeballs Version 2 is not provided when using TCPSocket.new on Windows.)
 *
 * If false, Happy Eyeballs Version 2 is disabled.
 *
 * For details on Happy Eyeballs Version 2,
 * see {Socket.tcp_fast_fallback=}[rdoc-ref:Socket#tcp_fast_fallback=].
 */
VALUE socket_s_tcp_fast_fallback(VALUE self) {
    return rb_ivar_get(rb_cSocket, tcp_fast_fallback);
}

/*
 * call-seq:
 *   Socket.tcp_fast_fallback= -> true or false
 *
 * Enable or disable Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
 * globally, which is provided starting from Ruby 3.4 when using TCPSocket.new and Socket.tcp.
 *
 * When set to true, the feature is enabled for both `TCPSocket.new` and `Socket.tcp`.
 * (Note: This feature is not available when using TCPSocket.new on Windows.)
 *
 * When set to false, the behavior reverts to that of Ruby 3.3 or earlier.
 *
 * The default value is true if no value is explicitly set by calling this method.
 * However, when the environment variable RUBY_TCP_NO_FAST_FALLBACK=1 is set,
 * the default is false.
 *
 * To control the setting on a per-method basis, use the fast_fallback keyword argument for each method.
 *
 * === Happy Eyeballs Version 2
 * Happy Eyeballs Version 2 ({RFC 8305}[https://datatracker.ietf.org/doc/html/rfc8305])
 * is an algorithm designed to improve client socket connectivity.<br>
 * It aims for more reliable and efficient connections by performing hostname resolution
 * and connection attempts in parallel, instead of serially.
 *
 * Starting from Ruby 3.4, this method operates as follows with this algorithm:
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
VALUE socket_s_tcp_fast_fallback_set(VALUE self, VALUE value) {
    rb_ivar_set(rb_cSocket, tcp_fast_fallback, value);
    return value;
}
```
