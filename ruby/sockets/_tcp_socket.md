# class TCPSocket
- [class TCPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/TCPSocket.html)

## 継承リスト
```
BasicObject
  |
Kernel
  |
Object
  |
File::Constants
  |
Enumerable
  |
IO
  |
BasicSocket
  |
IPSocket
  |
TCPSocket
```

## 接続を開く
### `.new`
- `new(host, service, local_host = nil, local_service = nil)` -> TCPSocket
  - (1) IPv4、コネクション型のソケットを生成
  - (2) 指定したホスト・ポートに対するソケットアドレスを取得
  - (3) ソケットアドレスに対してソケットを接続

```ruby
sock = Socket.new(:INET, ;STREAM)
addr = Socket.pack_sockaddr_in(port, host)
sock.connect(addr)
```
