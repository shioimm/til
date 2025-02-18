// 引用: ふつうのLinuxプログラミング
// 第15章 ネットワークプログラミングの基礎 2

// ソケット
//   ストリームの接続口
//   サーバーとクライアント両方を扱うことができる
//   TCP、UDP、IP、インターネット以外のネットワークプロトコルも扱うことができる

// #include <sys/socket.h>
// #include <sys/types.h>
// int socket(int domain, int type, int protocol);
//   ソケットを生成し、対応するファイルディスクリプタを返す
//     domain   - 通信を行なうドメイン
//     type     - 通信方式
//     protocol - プロトコル
//
// int connect(int sock, const struct sockaddr *addr, socklen_t addrlen);
//   sockからストリームを伸ばし、addrで示すサーバーにストリームを接続する
//     addr - IPアドレスとポート番号
//
// int bind(int sock, struct sockaddr *addr, socklen_t addrlen);
//   接続を待つaddrをsockに割り当てる
//
// int listen(int sock, int backlog);
//   sockがサーバー用のソケットであることをカーネルに知らせる
//
// int accept(int sock, struct sockaddr *addr, socklen_t addrlen);
//   sockにクライアントが接続をしてくるのを待ち、
//   接続が完了したら接続済みストリームのファイルディスクリプタを返す
//
// サーバー
//   1. socket(2)
//   2. bind(2)
//   3. listen(2)
//   4. accept(2)
//
// クライアント
//   1. socket(2)
//   2. connect(2)
