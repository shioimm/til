# socketライブラリ
- [library socket](https://docs.ruby-lang.org/ja/2.7.0/library/socket.html)

## ソケット関連クラス
- [class BasicSocket](https://docs.ruby-lang.org/ja/2.7.0/class/BasicSocket.html) - 抽象クラス

### 汎用ソケットクラス
- [class Socket](https://docs.ruby-lang.org/ja/2.7.0/class/Socket.html)

### インターネットドメインソケットクラス
- [class IPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/IPSocket.html) - インターネットドメインソケット抽象クラス
  - -> [class TCPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/TCPSocket.html) - TCP/IPストリーム型ソケット抽象クラス
    - -> [class TCPServer](https://docs.ruby-lang.org/ja/2.7.0/class/TCPServer.html) - TCP/IPストリーム型サーバー用ソケットクラス
  - -> [class UDPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/UDPSocket.html) - UDP/IPデータグラム型ソケットクラス

### UNIXドメインストリーム型ソケットクラス
- [class UNIXSocket](https://docs.ruby-lang.org/ja/2.7.0/class/UNIXSocket.html) - UNIXドメインストリーム型ソケット抽象クラス
  - -> [class UNIXServer](https://docs.ruby-lang.org/ja/2.7.0/class/UNIXServer.html) - UNIXドメインストリーム型サーバー用ソケットクラス

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
  |- Socket
  |
  |- IPSocket
  |    |- TCPSocket
  |         |- TCPServer
  |
  |- UNIXSocket
       |- UNIXServer
```

## アドレス情報クラス
- [class Addrinfo](https://docs.ruby-lang.org/ja/2.7.0/class/Addrinfo.html) - ソケットのアドレス情報

## ソケットオプションクラス
- [class Socket::Option](https://docs.ruby-lang.org/ja/2.7.0/class/Socket=3a=3aOption.html)

## 名前解決ライブラリ
- [library resolv](https://docs.ruby-lang.org/ja/2.7.0/library/resolv.html)
 - マルチスレッド環境において、DNS検索中にブロックするGVLを解除する
  - [library resolv-replace](https://docs.ruby-lang.org/ja/2.7.0/library/resolv=2dreplace.html)
    - 名前解決に`resolv`を使用するためのライブラリ

## OpenSSLライブラリ
- [library openssl](https://docs.ruby-lang.org/ja/2.7.0/library/openssl.html)

## 定数の定義
- [module Socket::Constants](https://docs.ruby-lang.org/ja/2.7.0/class/Socket=3a=3aConstants.html) - ソケット操作の指定のための定数

### 通信領域
- `AF_INET` / `PF_INET` (`:INET`) -> IPv4
- `AF_INET6` / `PF_INET6` (`:INET6`) -> IPv6
- `AF_LOCAL` / `AF_UNIX` / `PF_LOCAL` / `PF_UNIX` (`:UNIX`) -> Unixドメインソケット

### 通信形式
- `SOCK_STREAM` (`:STREAM`) -> ストリーム通信
- `SOCK_DGRAM` (`:DGRAM`) -> データグラム通信
