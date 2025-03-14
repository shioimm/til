# class TCPServer
- [class TCPServer](https://docs.ruby-lang.org/ja/2.7.0/class/TCPServer.html)

## TL;DR
- TCP/IPストリーム型サーバー用ソケットクラス

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
  |
TCPServer
```

## サーバー接続を開く
### `.new`
- `new(host = nil, service)` -> TCPServer
  - (1) IPv4、コネクション型のソケットを生成
  - (2) ソケットアドレスを取得
  - (3) 指定したソケットアドレスをソケットにバインドする
  - (4) レシーバーとなるソケットをリッスンさせる
    - リスナーキューは5つ

```ruby
sock = Socket.new(:INET, ;STREAM)
addr = Socket.pack_sockaddr_in(port, host)
sock.bind(addr)
sock.listen(5)
```

## `accept(2)`
### `#accept`
- `.accept` -> TCPSocket
  - リスナーキューから接続をpopし、接続を受け付ける
  - 新しい接続に対する新しい接続済みソケットを返す

### `#accept_nonblock`
- `accept_nonblock` -> TCPSocket
  - ソケットをノンブロッキングモードに設定し、接続を受け付ける
    - データが送信されていない場合、ブロックせず`Errno::EAGAIN`を返す
  - 新しい接続に対する新しい接続済みソケットを返す
