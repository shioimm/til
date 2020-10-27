# socketライブラリ
- [library socket](https://docs.ruby-lang.org/ja/2.7.0/library/socket.html)

## ソケットクラス
- [class BasicSocket](https://docs.ruby-lang.org/ja/2.7.0/class/BasicSocket.html) - ソケットの抽象クラス
  - -> [class Socket](https://docs.ruby-lang.org/ja/2.7.0/class/Socket.html) - 汎用ソケットのクラス
  - -> [class IPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/IPSocket.html) - インターネットドメインソケットの抽象クラス
    - -> [class TCPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/TCPSocket.html) - TCP/IPストリーム型ソケットのクラス
      - -> [class TCPServer](https://docs.ruby-lang.org/ja/2.7.0/class/TCPServer.html) - TCP/IPストリーム型サーバー用ソケットのクラス
    - -> [class UDPSocket](https://docs.ruby-lang.org/ja/2.7.0/class/UDPSocket.html) - UDP/IPデータグラム型ソケットのクラス
  - -> [class UNIXSocket](https://docs.ruby-lang.org/ja/2.7.0/class/UNIXSocket.html) - UNIXドメインストリーム型ソケットのクラス
    - -> [class UNIXServer](https://docs.ruby-lang.org/ja/2.7.0/class/UNIXServer.html) - UNIXドメインストリーム型のサーバ用ソケットのクラス

### BasicSocket以前の継承関係
- [BasicObject](https://docs.ruby-lang.org/ja/2.7.0/class/BasicObject.html)
  -> [Kernel](https://docs.ruby-lang.org/ja/2.7.0/class/Kernel.html)
  -> [Object](https://docs.ruby-lang.org/ja/2.7.0/class/Object.html)
  -> [File::Constants](https://docs.ruby-lang.org/ja/2.7.0/class/File=3a=3aConstants.html)
  -> [Enumerable](https://docs.ruby-lang.org/ja/2.7.0/class/Enumerable.html)
  -> [IO](https://docs.ruby-lang.org/ja/2.7.0/class/IO.html)
  -> BasicSocket

## アドレス情報クラス
- [class Addrinfo](https://docs.ruby-lang.org/ja/2.7.0/class/Addrinfo.html) - ソケットのアドレス情報

## 定数の定義
- [module Socket::Constants](https://docs.ruby-lang.org/ja/2.7.0/class/Socket=3a=3aConstants.html) - ソケット操作の指定のための定数

### 通信領域
- `AF_INET` / `PF_INET` (`:INET`) -> IPv4
- `AF_INET6` / `PF_INET6` (`:INET6`) -> IPv6
- `AF_LOCAL` / `AF_UNIX` / `PF_LOCAL` / `PF_UNIX` (`:UNIX`) -> Unixドメインソケット

### 通信形式
- `SOCK_STREAM` (`:STREAM`) -> ストリーム通信
- `SOCK_DGRAM` (`:DGRAM`) -> データグラム通信
