# SSLSocket

```
# 中間証明証を取得し、.pem形式で保存する
$ openssl s_client -connect www.example.com:443 -showcerts
```

```ruby
require 'socket'
require 'openssl'
include OpenSSL

hostname = 'www.example.com'
port = 443

socket = Socket.tcp(hostname, port)
store = OpenSSL::X509::Store.new
cert_file = "/path/to/???.pem"

store.add_file(cert_file)
store.set_default_paths

ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.cert_store = store

begin
  ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
  ssl_socket.connect
  ssl_socket.post_connection_check(hostname)
  if ssl_socket.verify_result != OpenSSL::X509::V_OK
    # ここでssl_socket.verify_resultを確認して具体的にどんなエラーが発生しているか確認したほうが良いかも
    raise "verification error"
  end
  ssl_socket.puts "GET / HTTP/1.1\r\nHost: #{hostname}\r\n\r\n"
  print ssl_socket.peer_cert.to_text
rescue OpenSSL::SSL::SSLError => e
  put e.message
ensure
  ssl_socket.close
  socket.close
end
```
