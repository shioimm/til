# HTTPSサーバ

```ruby
require 'webrick'
require 'webrick/https'

cert = OpenSSL::X509::Certificate.new(File.read('../ruby/test/net/fixtures/server.crt'))
pkey = OpenSSL::PKey::RSA.new(File.read('../ruby/test/net/fixtures/server.key'))

server = WEBrick::HTTPServer.new(
  BindAddress: 'localhost',
  Port: 12345,
  DocumentRoot: './',
  SSLEnable: true,
  SSLCertificate: cert,
  SSLPrivateKey: pkey
)

trap('INT') { server.shutdown }
server.start
```

```ruby
# クライアント
require 'socket'
require 'openssl'

ssl_sock = OpenSSL::SSL::SSLSocket.new(
  TCPSocket.new("localhost", 12345),
  OpenSSL::SSL::SSLContext.new
)
ssl_sock.connect
ssl_sock.puts "GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n"
p ssl_sock.gets
ssl_sock.close
```
