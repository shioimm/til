# Socket初期化時のコールグラフ
- `Init_socket` (socket.c)
  - `rsock_init_socket_init` (init.c)
    - `rsock_init_tcpsocket` (tcpsocket.c)
      - `TCPSocket.new`: `tcp_init` -> `rsock_init_inetsock` -> ...

#### 観点
- `Init_socket`でBasicSocketとSocketの初期化を行う
- `Init_socket`から`rsock_init_...`を呼び出すことでSocketのエラークラスと子クラスの初期化を行う
- `tcp_init`よりも手前で`tcp_fast_fallback`を定数化・初期化し、`tcp_init`でそれを参照する必要がある

## `id_error_code`の場合
- init.cに`static ID id_error_code;`を定義
- `rsock_init_socket_init` (init.c) で定数化
  - `SocketError`が`rsock_init_socket_init`の中で定義されているため

## `tcp_fast_fallback`の場合
### 案 (1)
- tcpsocket.cに`ID @tcp_fast_fallback`と`Init_socket_tcpsocket`を追加
- `Init_socket`から`Init_socket_tcpsocket`を呼び出す
- `Init_socket_tcpsocket` (tcpsocket.c) で`tcp_fast_fallback`を定数化 / 初期化

### 案 (2)
- init.c に`ID tcp_fast_fallback`を定義
- `rsock_init_socket_init` (init.c) で定数化 / 初期化
