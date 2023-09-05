# CによるRFC6555実装 (参考)
- https://github.com/shtrom/happy-eyeballs-c/
  - https://github.com/shtrom/happy-eyeballs-c/blob/9bd5cf9ff10d53bf7958dab470e7aee84a497e76/main.c

```c
// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/select.h>
#include <sys/time.h>

#include <sys/timeb.h>

#define MAX(a,b) (((a)>(b))?(a):(b))

struct app_config {
  char *host;
  char *service;
};

int parse_argv(struct app_config *conf, int argc, char ** argv);
int connect_gai(char *host, char *service);
int connect_rfc6555(char *host, char *service);
int socket_create(struct addrinfo *rp);
int rfc6555(struct addrinfo *result, int sfd);
struct addrinfo *find_ipv4_addrinfo(struct addrinfo *result);
void print_delta(struct timeb *start, struct timeb *stop);
int try_read(int sfd);

int main(int argc, char **argv) {
  struct app_config conf;
  int ret = 0;
  int sfd = 0;
  struct timeb start_all, start, stop;

  // 引数のバリデーション
  if (0 != (ret = parse_argv(&conf, argc, argv))) {
    fprintf(stderr, "error: parsing arguments: %d\n", ret);
    fprintf(stderr, "usage: %s HOST PORT\n", argv[0]);
    return ret;
  }

  fprintf(stderr, "happy-eyeballing %s:%s ... \n", conf.host, conf.service);

  // start_all に全ての処理の開始時刻を設定
  ftime(&start_all);
  // start に接続試行の開始時刻を設定
  ftime(&start);

  // sfd に接続済み、もしくは接続中のソケットの fd を格納
  if((sfd = connect_rfc6555(conf.host, conf.service)) < 0) {
    fprintf(stderr, "error: connecting: %d\n", sfd);
    return sfd;
  }

  // stop にソケットからの接続試行の終了時刻を格納
  ftime(&stop);
  print_delta(&start, &stop);

  fprintf(stderr, "reading ...\n");

  // start に読み出しの開始時刻を設定
  ftime(&start);

  if ((ret = try_read(sfd)) < 0) {
    fprintf(stderr, "error: reading: %d\n", ret);
    return ret;
  }

  // stop にソケットからの読み出しの終了時刻を格納
  ftime(&stop);

  print_delta(&start, &stop);
  print_delta(&start_all, &stop);

  return ret;
}

// 引数で渡されたホスト名・ポート番号を app_config にセットする
int parse_argv(struct app_config *conf, int argc, char ** argv) {
  if (argc < 3) {
    return -1;
  }

  conf->host = strdup(argv[1]);
  conf->service = strdup(argv[2]);

  return 0;
}

/*
   Variation on the above, to implement RFC6555.
   Licensing terms for this function can be found at [0].
   [0] http://man7.org/linux/man-pages/man3/getaddrinfo.3.license.html
 */
// アドレス解決、ソケットの作成、接続試行を行い、接続済み、もしくは接続中のソケットの fd を返す
int connect_rfc6555(char *host, char *service) {
  struct addrinfo hints;
  struct addrinfo *result, // getaddrinfo で取得した addrinfo を格納
                  *rp;     // getaddrinfo で取得した addrinfo のリストの各要素を格納
  int sfd, // 接続するソケットの fd を格納
      s;   // getaddrinfo の結果を格納

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;    /* Allow IPv4 or IPv6 */
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags |= AI_CANONNAME;
  hints.ai_protocol = 0;          /* Any protocol */

  // アドレス解決 (result に addrinfo を格納)
  s = getaddrinfo(host,service, &hints, &result);
  if (s != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
    exit(EXIT_FAILURE);
  }

  /*
     getaddrinfo() returns a list of address structures.
     Try each address until we successfully connect(2).
     If socket(2) (or connect(2)) fails, we (close the socket and) try the next address.
   */

  // アドレス在庫が枯渇するか、接続済みまたは接続中のソケットを取得できるまでループ
  for (rp = result; rp != NULL; rp = rp->ai_next) {
    // ノンブロッキングモードのソケットを作成
    sfd = socket_create(rp);

    if (sfd == -1) {
      continue;
    }

    if (connect(sfd, rp->ai_addr, rp->ai_addrlen) != -1) {
      break; // 接続に成功、sfd に接続済みソケットを格納
    }

    // 接続中
    if (EINPROGRESS == errno) {
      fprintf(stderr, " in progress ... \n");

      if((sfd = rfc6555(rp, sfd)) > -1) {
        break; // 接続に成功、sfd に接続済みソケットを格納
      } // sfd が -1 の場合は次のループへスキップ
    }

    perror("error: connecting: ");
    close(sfd);
  }

  // アドレス在庫が枯渇 (接続に成功している場合、rp に試行した addrinfo が格納されているはず)
  if (rp == NULL) { /* No address succeeded */
    fprintf(stderr, "failed! (last attempt)\n");
    perror("error: connecting: ");
    return -3;
  }
  fprintf(stderr, " success: %d!\n", sfd);

  freeaddrinfo(result); /* No longer needed */

  // 接続済みのソケットの fd を返す
  return sfd;
}

// ソケットの作成と O_NONBLOCK フラグのセットを行う
int socket_create(struct addrinfo *rp) {
  int sfd;   // 接続するソケットの fd
  int flags; // 接続するソケットのフラグ

  fprintf(stderr, "connecting using rp %p (%s, af %d) ...", rp, rp->ai_canonname, rp->ai_family);

  // socket(2)
  sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);

  if (sfd == -1) {
    return -1;
  }

  // fd のファイル状態フラグを読み出してflagsに格納
  flags = fcntl(sfd, F_GETFL,0);
  // O_NONBLOCK をセットした flags を sfd にセット
  fcntl(sfd, F_SETFL, flags | O_NONBLOCK);

  return sfd;
}

// struct addrinfo *result = 接続先の addrinfo
// int sfd = 接続中のソケットの fd
int rfc6555(struct addrinfo *result, int sfd) {
  fd_set readfds, writefds;
  int ret;
  struct addrinfo *rpv4; // IPv4 addrinfo を格納する
  int sfdv4;

  // RFC6555での Connection Attempt Delay は 300ms
  struct timeval timeout = { 0, 300000 }; /* 300ms */

  FD_ZERO(&readfds);
  FD_ZERO(&writefds);
  FD_SET(sfd, &readfds);  // sfd を read 監視対象にセット
  FD_SET(sfd, &writefds); // sfd を write 監視対象にセット

  fprintf(stderr, "info: waiting for 300ms ...\n");

  // Connection Attempt Delay まで接続を待機
  /* select with 300ms TO */
  if((ret = select(sfd + 1, &readfds, &writefds, NULL, &timeout)) < 0)  {
    // select(2) に失敗
    perror("error: initial timeout");
    return -1;
  }

  // Connection Attempt Delay 中に接続確立できた
  if (ret == 1) {
    return sfd;
  }

  // ここから先は Connection Attempt Delay がタイムアウトした場合の処理
  fprintf(stderr, "info: still in progress, finding IPv4 ...\n");

  // IPv4 の addrinfo を取得
  /* find IPv4 address */
  if (NULL == (rpv4 = find_ipv4_addrinfo(result->ai_next))) {
    fprintf(stderr, "error: none found, IPv6 selected\n");
    return sfd;
  }

  // IPv4 の addrinfo でソケットを作成
  if (-1 == (sfdv4 = socket_create(rpv4))) {
    perror("error: setting up IPv4 socket");
    return sfd;
  }

  // 作成したソケットで接続試行
  if (connect(sfdv4, rpv4->ai_addr, rpv4->ai_addrlen) != 0) {
    if (EINPROGRESS == errno) {
      fprintf(stderr, " in progress ... \n");
    } else {
      perror("error: connecting: ");
      close(sfdv4);
      return sfd;
    }
  }

  FD_ZERO(&readfds);
  FD_ZERO(&writefds);
  FD_SET(sfd, &readfds);    // sfd を read 監視対象にセット
  FD_SET(sfdv4, &readfds);  // sfdv4 を read 監視対象にセット
  FD_SET(sfd, &writefds);   // sfd を write 監視対象にセット
  FD_SET(sfdv4, &writefds); // sfdv4 を write 監視対象にセット

  fprintf(stderr, "info: waiting for any socket ...\n");

  // Connection Attempt Delay まで接続を待機
  /* select with 300ms TO */
  if((ret = select(MAX(sfd,sfdv4)+1, &readfds, &writefds, NULL, NULL /* &timeout */)) < 0) {
    perror("error: second timeout");
    return -1;
  }

  // 返ってきた fd があればそれを返す (IPv6を優先したい)
  // 返り値ではない方のソケットを close する必要がありそう
  if (ret >= 1) {
    if (FD_ISSET(sfd, &readfds) || FD_ISSET(sfd, &writefds)) {
      fprintf(stderr, "info: IPv6 selected\n");
      return sfd;
    } else if (FD_ISSET(sfdv4, &readfds) || FD_ISSET(sfdv4, &writefds)) {
      fprintf(stderr, "info: IPv4 selected\n");
      return sfdv4;
    }
  }
  return -1;
}

// 取得した addrinfo のリストからIPv4アドレスを選択
// いい案な気がするけど、Connection Attempt Delayがタイムアウトするまでアドレス解決を保留しているのが課題
// (RFC8305では非同期でアドレス解決する必要あり)
// これを参考にする場合、
//   1. 先に IPv4 の addrinfo のリストと IPv6 の addrinfo のリストを取得しておく必要あり
//      (非同期処理・リストを得た時点から接続試行が可能になる)
//   2. 関数を呼ぶ側で、前回使用したアドレスファミリではないアドレスファミリの addrinfo のリストを引数に渡す必要あり
struct addrinfo *find_ipv4_addrinfo(struct addrinfo *result) {
  // リストの途中の addrinfo を渡すことで次の addrinfo を取得することができる
  for (; result != NULL; result = result->ai_next) {
    fprintf(stderr, "info: considering %s (%d) ... \n",　result->ai_canonname, result->ai_family);

    if (AF_INET == result->ai_family) {
      return result;
    }
  }

  return NULL;
}

void print_delta(struct timeb *start, struct timeb *stop) {
  fprintf(stderr, "delta: %lds %dms\n", stop->time - start->time, stop->millitm-start->millitm);
}

int try_read(int sfd) {
  char buf[1024];
  ssize_t s;

  // fdから読み込み
  while((s = read(sfd, buf, sizeof(buf))) < 0) {
    if (EAGAIN != errno) {
      perror("error: reading: ");
      return -4;
    }
  }

  fprintf(stderr, "read: ");
  printf("%s\n", buf);

  return 0;
}
```

## やってみる
- アドレス取得の仕組みを実装
- Socket_tcp/impl14.rbの`ConnectionAttempt`をメソッドで表現する