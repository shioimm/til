# class Socket
- [class Socket](https://docs.ruby-lang.org/ja/2.7.0/class/Socket.html)

## ファイルディスクリプタ番号の取得
### `IO#fileno`
- `fileno` -> Integer
  - Socketオブジェクトのファイルディスクリプタ番号を返す

## `socket(2)`
### `.new`
- `new(domain, type, protocol = 0) -> Socket`
  - 指定した通信領域、通信形式によるソケットを生成

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

