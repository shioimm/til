// 引用: ふつうのLinuxプログラミング
// 第15章 ネットワークプログラミングの基礎 3

// getaddrinfo()
//   ホスト名・サービス名からIPアドレス・ポート番号を得る
//
// getnameinfo()
//   IPアドレス・ポート番号からホスト名・サービス名を得る

// #include <sys/socket.h>>
// #include <sys/types.h>
// #include <netdb.h>
// int getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res);
//   接続対象nodeのアドレス候補をresに書き込む
//   必要な情報を限定するためにserviceとhintsで絞り込む
//
// void freeaddrinfo(struct addrinfo *res);
//   struct addrinfoのメモリ領域(mallocで確保されている)を解放する
//
// const char *gai_strerror(int err);
//   getaddrinfo()の失敗時のエラーコードを文字列に直す
//
// struct addrinfo {
//   int      ai_flags;
//   int      ai_family;
//   int      ai_socktype;
//   int      ai_protocol;
//   strlen_t ai_addrlen;
//   struct   sockaddr *ai_addr;
//   char     *ai_canonname;
//   struct   addrinfo *ai_next; リンクリストになっている
// }
