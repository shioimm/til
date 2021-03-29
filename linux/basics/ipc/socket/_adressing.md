# アドレシング
- 参照: 例解UNIX/Linuxプログラミング教室P291-322
- 参照: 詳解UNIXプログラミング第3版 16. ネットワークIPC: ソケット
- 参照: Linuxプログラミングインターフェース 56章

## TL;DR
- 通信先となるプロセスを識別する
  - ネットワークアドレス - ネットワーク上のコンピュータを識別
  - ポート番号 - コンピュータ上の特定のプロセスの識別

### バイトオーダー
- マルチバイトデータ型のバイトの配置順序
- プロセッサアーキテクチャによって変わる
  - リトルエンディアン - 最高位バイトアドレスが最上位バイト(MSB)
  - ビッグエンディアン - 最高位バイトアドレスが最下位バイト(LSB)
  - TCP/IPプロトコルはビッグエンディアン
    - 通信時、ホストバイトオーダーをネットワークバイトオーダーにに合わせる必要がある
- `htonl(3)` - ネットワークバイトオーダーでの32ビット整数を返す
- `htons(3)` - ネットワークバイトオーダーでの16ビット整数を返す
- `ntohl(3)` - ホストバイトオーダーでの32ビット整数を返す
- `ntohs(3)` - ホストバイトオーダーでの16ビット整数を返す

### アドレス形式
- 特定の通信ドメイン内のソケット端点を識別する
- サーバーソケット・クライアントソケットで同じ型の構造体を使用する

```c
// sockaddr構造体 - ソケット固有のアドレスのデータを保存する汎用アドレス構造体
// 16バイト

struct sockaddr {
  sa_family_t sa_family; // アドレスファミリ
  char        sa_data[]; // 可変長アドレス
};
```

```c
// sockaddr_in構造体 - TCP(IPv4)を使用する際に使用するsockaddr構造体
// 16バイト

struct sockaddr_in {
  sa_family_t    sin_family;  // アドレスファミリ(AF_INET)
  in_port_t      sin_port;    // ポート番号
  struct in_addr sin_addr;    // IPv4アドレス(INADDR_ANY)
};

// INET6領域のアドレスファミリを使用する場合はsockaddr_in6構造体(28バイト)
// UNIX領域のアドレスファミリを使用する場合はsockaddr_un構造体を使用する
```

```c
// in_addr構造体 - IPアドレスを記述する構造体

struct in_addr {
  inaddr_t s_addr; // IPv4アドレス
};

// IPv6アドレスを扱う場合はin6_addr構造体を使用する

// sin_portとs_addrはマルチバイト整数・ビッグエンディアン(ネットワークバイトオーダ)
```
- `inet_ntop(3)` - ネットワークバイトオーダーのバイナリアドレスをテキスト文字列に変換
- `inet_pton(3)` - テキスト文字列をネットワークバイトオーダーのバイナリアドレスに変換

```c
// 受信時にバイト数が不明の場合
// 128バイト

struct sockaddr_storage {
  sa_family_t ss_family;   // アドレスファミリ
  char        sa_data[14]; // 任意のデータ
};

// 任意のsockaddr構造体(sockaddr_in / sockaddr_in6)を格納できる入れ物として機能する
```

### アドレス探索
#### ネットワーク構成情報
- ネットワーク構成情報は様々な場所に格納されうる
  - `/etc/services` / `/etc/hosts`
  - DNS
  - NIS
- `gethostent(3)` - 当該コンピュータシステムのホストデータベースファイルを取得

```c
struct hostent {
  char  *h_name;      // ホスト名
  char **h_aliases;   // ホスト別名配列へのポインタ
  int    h_addtype;   // アドレス種別
  int    h_length;    // アドレスのバイト長
  char **h_addr_list; // ネットワークアドレスの配列へのポインタ
};
```

- `getnetbyaddr(3)` - ホスト名ではなくネットワーク名からネットワークアドレスを得る

```c
struct netent {
  char      *n_name;     // ネットワーク名
  char     **n_aliases;  // ネットワーク別名配列へのポインタ
  int        n_addrtype; // アドレス種別
  uint32_t   n_net;      // ネットワーク番号
};
```

- `getprotobyname(3)` / `getprotobynumber(3)` / `getprotent(3)` - プロトコル名と番号のマップ

```c
struct protent {
  char  *p_name;    // プロトコル名
  char **p_aliases; // プロトコル別名配列へのポインタ
  int    p_proto;   // プロトコル番号
};
```

- `getservbyname(3)` / `getservbyport` / `getservent` - サービス名とポート番号のマップ

```c
struct servent {
  char  *s_name;    // サービス名
  char **s_aliases; // サービス別名配列へのポインタ
  int    s_port;    // ポート番号
  char  *s_proto;   // プロトコル名
};
```

- `getaddrinfo(3)` - ホスト名とサービス名をアドレスにマップする
- `getnameinfo(3)` - アドレスをホスト名とサービス名に変換する
  - アドレスの情報を格納する`addrinfo`構造体の連結リストを返す
  - プロトコルファミリに依存しないため、`gethostbyname(3)`に代わって使用される

```c
// 48バイト

struct addrinfo {
  int             ai_flags;      // 振る舞いを指定
  int             ai_family;     // アドレスファミリ(AF_UNSPEC)
  int             ai_socktype;   // ソケットの型
  int             ai_protocol;   // プロトコル
  socklen_t       ai_addrlen;    // アドレスのバイト長
  struct sockaddr *ai_addr;      // sockaddr構造体(ソケットアドレス)へのポインタ
  char            *ai_canonname; // 正規ホスト名
  struct addrinfo *ai_next;      // アドレスリンクリストの次の要素
};

// ai_flagsにAI_PASSIVEを指定することで
// INADDR_ANY / inaddr6anyの切り分けや
// sockaddr_in構造体 / sockaddr_in6構造体の切り分けが不要になる
```

### プロトコル独立な実装
- 特定のアドレスファミリに依存しない実装

```c
// 参照: 例解UNIX/Linuxプログラミング教室P320

#include <sys/types.h>  // socket, connect, read, write, freeaddrinfo, getaddrinfo, gai_strerror
#include <sys/socket.h> // socket, connect, shutdown, freeaddrinfo, getaddrinfo, gai_strerror
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // memset
#include <sys/uio.h>    // read, write
#include <unistd.h>     // close, read, write
#include <netdb.h>      // reeaddrinfo, getaddrinfo, gai_strerror

char *httpreq = "GET / HTTP/1.0 \r\n\r\n";

int main()
{
  int             s, cc;
  struct addrinfo hints, *addrs;
  char            buf[1024];

  memset(&hints, 0, sizeof(hints));
  hints.ai_family   = AF_UNSPEC;   // アドレスファミリの規定なし
  hints.ai_socktype = SOCK_STREAM; // コネクション型バイトストリーム

  if ((cc = getaddrinfo("localhost", "http", &hints, &addrs)) != 0) {
    fprintf(stderr, "getaddrinfo' %s\n", gai_strerror(cc));
  }

  if ((s = socket(addrs->ai_family, addrs->ai_socktype, addrs->ai_protocol)) < 0) {
    perror("socket");
    exit(1);
  }

  if (connect(s, addrs->ai_addr, addrs->ai_addrlen) < 0) {
    perror("connect");
    exit(1);
  }

  freeaddrinfo(addrs);

  write(s, httpreq, strlen(httpreq));

  while ((cc = read(s, buf, sizeof(buf))) > 0) {
    write(1, buf, cc);
  }

  shutdown(s, SHUT_RDWR);
  close(s);

  return 0;
}
```

## ホスト名からIPアドレスへの変換
- `gethostbyname(3)` - 指定したホスト名をIPアドレスに変換し`hostent`構造体へのポインタを返す
  - IPv4の名前解決しかできない
```c
// hostent構造体
struct  hostent {
  char *h_name;       // ホストの正式名
  char **h_aliases;   // ホストの別名の配列
  int  h_addrtype;    // アドレスファミリ(AF_INET)
  int  h_length;      // アドレスのバイト数(4)
  char **h_addr_list; // IPアドレスの配列
};

// エラーコード
// HOST_NOT_FOUND ホストが存在しない
// NO_DATA        適切なIPアドレスが見つからない
// NO_RECOVERY    検索中のエラー
// TRY_AGAIN      要再試行
```
