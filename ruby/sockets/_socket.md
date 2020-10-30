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

## ファイルディスクリプタ番号の取得
### `IO#fileno`
- `fileno` -> Integer
  - Socketオブジェクトのファイルディスクリプタ番号を返す

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

## `close(2)`
### `#close`
- `close` -> nil
  - ストリームの削除
  - 同じファイルディスクリプタを持つ他のストリームに対しては削除を実行しない

## `shutdown(2)`
### `BasicSocket#shutdown`
- `shutdown(how = Socket::SHUT_RDWR)` -> 0
  - ストリームの削除
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
  - 指定のソケットアドレスに対してクライアントして接続
  - ソケットアドレスは`Socket#pack_sockaddr_in`の返り値のバイナリか`Addrinfo`オブジェクト

## サーバー接続
### `.tcp`
- `tcp(host, port, local_host = nil, local_port = nil) {|socket| ... }` -> object
  - TCP/IPのソケットを生成し、指定したホスト・ポート番号を持つソケットアドレスに対して接続
  - サーバーとの接続が確立すると、接続したソケットブロックに渡し呼び出す
  - ブロック終了時にソケットオブジェクトを閉じる
