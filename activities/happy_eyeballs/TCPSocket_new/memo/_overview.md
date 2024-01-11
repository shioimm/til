# 全体構造
1. `rsock_init_tcpsocket` (ext/socket/tcpsocket.c)
    - `TCPSocket#initialize`の定義
2. `tcp_init` (ext/socket/tcpsocket.c)
    - メソッドの引数を処理して`rsock_init_inetsock`を呼び出す
3. `rsock_init_inetsock` (ext/socket/ipsocket.c)
    - `struct inetsock_arg arg`を`init_inetsock_internal`用の引数として用意
    - `init_inetsock_internal`を呼び出す
4. `init_inetsock_internal` (ext/socket/ipsocket.c)
    - `rsock_addrinfo` (ext/socket/raddrinfo.c) - 名前解決
      - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)
        - `getaddrinfo(2)`
    - `rsock_socket` (ext/socket/init.c) - `socket(2)`の実行
      - `rsock_socket0` (ext/socket/init.c)
    - (`INET_SERVER`) `bind(2)`の実行
    - (`INET_SERVER`) `listen(2)`の実行
    - (`INET_SERVER`以外) `rsock_connect` (ext/socket/init.c) - `connect(2)`の実行
      - `rb_thread_io_blocking_region` (thread.c)
        - `connect(2)`
    - `rsock_init_sock` (ext/socket/init.c) - `Socket`オブジェクトを作成して返す
5. (ensure) `inetsock_cleanup` (ext/socket/ipsocket.c)

#### `rsock_init_inetsock`への依存
- `tcp_init` (ext/socket/tcpsocket.c) - `TCPSocket#initialize` (`INET_CLIENT`)
- `socks_init` (ext/socket/sockssocket.c ) - `SOCKSSocket#initialize` (`INET_SOCKS`)
- `tcp_svr_init` (ext/socket/tcpserver.c) - `TCPServer#initialize` (`INET_SERVER`)

#### HEv2対応の対象
- typeが`INET_CLIENT`
- `defined(F_SETFL)`
- `defined(F_GETFL)`
- `ifndef GETADDRINFO_EMU`
- `defined(HAVE_PTHREAD_CREATE)`
- `defined(HAVE_PTHREAD_DETACH)`
- `!defined(__MINGW32__)`
- `!defined(__MINGW64__)`
