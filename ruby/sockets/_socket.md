# class Socket
- [class Socket](https://docs.ruby-lang.org/ja/2.7.0/class/Socket.html)

## TL;DR
- 汎用ソケットクラス

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
Socket
```

## `socket(2)`
### `.new`
- `new(domain, type, protocol = 0) -> Socket`
  - 指定した通信領域、通信形式によるソケットを生成

### `.tcp_server_sockets`
- `tcp_server_sockets(host, port)` -> [Socket]
  - 指定したホスト・ポート番号でTCP/IPのリスニングソケットを作成

## ソケットアドレスの取得
### `#pack_sockaddr_in`
- `sockaddr_in(port, host)` / `pack_sockaddr_in(port, host)` -> String
  - 指定したポート番号・ホストに対して
    `sockaddr_in`構造体(あるいは`sockaddr_un`構造体)を作成
    バイナリとしてpackした文字列を返す

## `bind(2)`
### `#bind`
- `bind(my_sockaddr)` -> 0
  - 指定したソケットアドレスをソケットにバインドする
  - ソケットアドレスは`Socket#pack_sockaddr_in`の返り値のバイナリか`Addrinfo`オブジェクト

## `listen(2)`
### `#listen`
- `listen(backlog = 5)` / `listen(backlog = 5) { |sock| ... }` -> Socket
  - レシーバーとなるソケットをリッスンさせる
  - 指定したバックログ数分のリスナーキューを持たせる
  - 指定したバックログ数を越す接続に対して`Errno::ECONNREFUSED`を発生させる

## `accept(2)`
### `#accept`
- `accept` -> Array
  - リスナーキューから接続をpopし、接続を受け付ける
  - 新しい接続に対する新しい接続済みソケットと`Addrinfo`オブジェクトのペアを配列で返す
    - 接続済みソケットはリスニングソケットとは別に新たに生成されるもの
    - `Addrinfo`オブジェクトはクライアントからのリモートアドレスを格納するもの
  - 接続を受け付けるまでの間は処理をブロックする

### `#accept_nonblock`
- `accept_nonblock` -> Array
  - ソケットをノンブロッキングモードに設定し、接続を受け付ける
    - データが送信されていない場合、ブロックせず`Errno::EAGAIN`を返す

## `close(2)`
### `#close`
- `close` -> nil
  - ストリームの削除
  - 同じファイルディスクリプタを持つ他のストリームに対しては削除を実行しない

## `shutdown(2)`
### `BasicSocket#shutdown`
- `shutdown(how = Socket::SHUT_RDWR)` -> 0
  - 指定したストリームの削除
    - クライアントが書き出しを`shutdown`した場合: サーバーは受信バッファを読み出し後、EOFを受信
    - クライアントが読み出しを`shutdown`した場合: クライアントは受信バッファ読み出し後、EOFを受信
  - 同じファイルディスクリプタを持つ他のストリームに対しても削除を実行する

### `IO#close_read`
- `close_read` -> nil
  - 読み込み用ストリームの削除

### `IO#close_write`
- `close_write` -> nil
  - 書き込み用ストリームの削除

## リスニングループ
### `.accept_loop`
- `accept_loop(sockets) { |sock, client_addrinfo| ... }` -> ()
  - ソケットの配列を受け取り、リッスンさせる
    - 配列のいずれかの要素でリッスンする
  - クライアントとの接続が確立すると、接続用ソケットとAddrinfoオブジェクトをブロックに渡し呼び出す
  - ブロック終了時に接続用ソケットのストリームは閉じないため明示的に`close`する必要がある
  - ブロックは逐次的に呼び出されるため、
    複数のクライアントと通信したい場合は別途並列機構を使う必要がある

### `.tcp_server_loop`
- `tcp_server_loop(host, port) { |sock,addr| ... }` -> ()
  - 指定したホスト・ポート番号でTCP/IPのソケットを生成し、リッスンさせる
  - クライアントとの接続が確立すると、接続用ソケットとAddrinfoオブジェクトをブロックに渡し呼び出す
  - ブロック終了時に接続用ソケットのストリームは閉じないため明示的に`close`する必要がある
  - ブロックは逐次的に呼び出されるため、
    複数のクライアントと通信したい場合は別途並列機構を使う必要がある

## `connect(2)`
### `#connect`
- `connect(server_sockaddr)` -> 0
  - 指定のソケットアドレスに対してクライアントとして接続
  - ソケットアドレスは`Socket#pack_sockaddr_in`の返り値のバイナリか`Addrinfo`オブジェクト

### `#connect_nonblock`
- `connect_nonblock(server_sockaddr)` -> 0
  - ソケットをノンブロッキングモードに設定し、指定のソケットアドレスに対してクライアントとして接続
    - 接続がブロックされている場合は`Errno::EINPROGRESS`が返され、バックグラウンドで接続操作を継続させる
    - 前回の接続がブロックされている場合は`Errno::EALREADY`が返される
```ruby
# 引用: Working with TCP Sockets P97
# multiplexing_connect.rb

require 'socket'

socket = Socket.new(:INET, :STREAM)
remote_addr = Socket.pack_sockaddr_in(80, 'google.com')

begin
  socket.connect_nonblock(remote_addr)
rescue Errno::EINPROGRESS
  IO.select(nil, [socket]) # サーバー接続を監視

  begin
    socket.connect_nonblock(remote_addr) # 書き込み可能になったら再接続
  rescue Errno::EISCONN # 接続済み(成功)
  rescue Errno::ECONNREFUSED # サーバーとの接続切れ
  end
end
```

## サーバー接続
### `.tcp`
- `tcp(host, port, local_host = nil, local_port = nil) {|socket| ... }` -> object
  - TCP/IPのソケットを生成し、指定したホスト・ポート番号を持つソケットアドレスに対して接続
  - サーバーとの接続が確立すると、接続したソケットブロックに渡し呼び出す
  - ブロック終了時にソケットオブジェクトを閉じる
