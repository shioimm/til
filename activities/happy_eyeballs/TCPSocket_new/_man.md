```
.Sh MISC ENVIRONMENT
.Pp
.Bl -hang -compact -width "RUBY_TCP_NO_FAST_FALLBACK"
.It Ev RUBY_TCP_NO_FAST_FALLBACK
If set to
.Li 1 ,
disables the fast fallback feature by default in TCPSocket.new and Socket.tcp.
When set to
.Li 0
or left unset, the fast fallback feature is enabled.
Introduced in Ruby 3.4, default: unset.
```
