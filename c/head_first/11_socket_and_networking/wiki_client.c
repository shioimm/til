/*
 * 引用: Head First C
 * 第11章 ソケットとネットワーキング 4
*/

/*
 * クライアント接続
 *   1. リモートポートに接続
 *     IPアドレス(またはホスト名) + ポート番号
 *     ホスト名はgetaddrinfo()でDNSから取得する
 *   2. やり取りを開始
 *
 * getaddrinfo()
 *   ヒープにネーミングリソースを作成
 *     特定のドメイン名を持つサーバーのポート
 *     IPアドレスの情報を持つ
 * freeaddrinfo()
 *   ヒープに作成したネーミングリソースを削除
*/

#include <netdb.h> /* getaddrinfo() */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int open_socket(char *host, char *port)
{
  struct addrinfo *res; /* addrinfo構造体 インターネットアドレスを格納 */
  struct addrinfo hints;
  memset(&hints, 0, sizeof(hints)); /* memset      hintsのメモリを0埋めする */
  hints.ai_family = PF_UNSPEC;      /* ai_family   アドレスファミリ */
  hints.ai_socktype = SOCK_STREAM;  /* ai_socktype 推奨のソケット型 */

  /* hostのport番号のネーミングリソースを作成 */
  if (getaddrinfo(host, port, &hints, &res) == -1) {
    error("アドレスを解決できません");
  }

  /* ソケットディスクリプタを生成 */
  int d_sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

  if (d_sock == -1) {
    error("ソケットを開けません");
  }

  int c = connect(d_sock, res->ai_addr, res->ai_addrlen); /* connect ソケットの接続を行う */
  freeaddrinfo(res);

  if (c == -1) {
    error("ソケットに接続できません");
  }

  return d_sock;
}

int say(int socket, char *s)
{
  int result = send(socket, s, strlen(s), 0);

  if (result == -1) {
    fprintf(stderr, "%s: %s\n", "サーバーとの通信エラー", strerror(errno));
  }

  return result;
}

int main(int argc, char *argv[])
{
  int d_sock;

  d_sock = open_socket("en.wikipedia.org", "80");

  char buf[255];

  sprintf(buf, "GET /wiki/%s http/1.1\r\n", argv[1]);
  say(d_sock, buf);
  say(d_sock, "Host: en.wikipedia.org\r\n\r\n");

  char rec[256];

  int bytesRcvd = recv(d_sock, rec, 255, 0); /* 受信したデータのバイト数を返す */

  while (1) {
    if (bytesRcvd == -1) {
      error("サーバーから読み込めません");
    }

    rec[bytesRcvd] = '\0';
    printf("%s", rec);
    bytesRcvd = recv(d_sock, rec, 255, 0);
  }

  close(d_sock);

  return 0;
}
