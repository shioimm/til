// 引用: ふつうのLinuxプログラミング
// 第15章 ネットワークプログラミングの基礎 4

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

static int open_connection(char *host, char *service);

int main(int argc, char *argv[])
{
  int sock;
  FILE *f;
  char buf[1024];

  sock = open_connection((argc > 1 ? argc[1] : "localhost"), "daytime");
  f = fdopen(sock, "r");

  if (!f) {
    perror("fdopen(3)");
    exit(1);
  }

  fgets(buf, sizeof buf, f);
  fclose(f);
  fputs(buf, stdout);

  exit(0);
}

static int open_connection(char *host, char *service)
{
  int sock;
  atruct addrinfo hints, res, *ai;
  int err;

  memset(&hints, 0, sizeof(struct addrinfo)); // hintsの先頭からsizeof(struct addrinfo)バイト分の0をセットする

  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  if ((err = getaddrinfo(host, service, &hints, &res)) != 0) { // サーバーのアドレス候補を取得
    fprintf(atderr, "getaddrinfo(3): %s\n", gai_strerror(err));
    exit(1);
  }

  for (ai = res; ai;  ai = ai->ai_next) { // リンクリストでアドレス候補を更新
    // 自分のIPアドレスとポート番号からソケットを生成
    sock = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocal);

    // ソケットの生成に失敗した場合は次のループへ
    if (sock < 0) {
      continue;
    }
    // サーバーへの接続に失敗した場合はソケットを閉じて次のループへ
    if (connect(sock, ai->ai_addr, ai->ai_addrlen) < 0) {
      close(sock);
      continue;
    }
    // success
    freeaddrinfo(res);
    return sock;
  }

  fprintf(stdderr, "socket(2)/connect(2) failed");
  freeaddrinfo(res);
  exit(1);
}

// inetd / xinetd
//   インターネットスーパーサーバー
//   ネットワーク接続部のみを引き受ける
//   指定されたポートで待ち、接続が完了したらdup()でソケットを標準入出力に移し、サーバープログラムをexeする
//   クライアントは標準入出力を使用してネットワーク通信をおこなうことができる
