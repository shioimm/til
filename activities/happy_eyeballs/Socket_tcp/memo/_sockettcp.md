# `Socket.tcp`

```ruby
require 'socket'

Socket.tcp("www.ruby-lang.org", 80) {|sock|
  sock.print "GET / HTTP/1.0\r\nHost: www.ruby-lang.org\r\n\r\n"
  sock.close_write
  puts sock.read
}
```

- hostを名前解決する
  - アドレスファミリとして`AF_INET6`を指定する`Addrinfo.getaddrinfo`と
    アドレスファミリとして`AF_INET`を指定する`Addrinfo.getaddrinfo`を同時に実行
- host/portにクライアントソケットとして接続し、接続が確立したソケットを返す
