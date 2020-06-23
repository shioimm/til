/*
 * 引用: Head First C
 * 第11章 ソケットとネットワーキング 1
*/

/*
 * BLAB
 *   0. 準備
 *     ソケットディスクリプタAを生成
 *   1. bind
 *     通信に使用するポートをバインドする(一般的に1024番以上)
 *     ソケットディスクリプタA / ソケット名(struct)
 *   2. listen
 *     クライアントからの接続待ち
 *     接続可能なクライアントの数を設定する
 *   3. accept
 *     クライアントからの接続を受け入れ
 *     ソケットディスクリプタBを生成(通信を開始・維持するため)
 *   4. begin
 *     ソケットディスクリプタBによって接続を開始
 *
 * ソケットは入力と出力の双方向に通信を行うことができる
 * send()関数でデータを出力する
 * recv()関数でデータを入力する
*/

#include <sys/socket.h> /* ソケット */
#include <arpa/inet.h>  /* インターネットアドレスを作成 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int main(int argc, char *argv[])
{
  char *advice[] = {
    "食べる量を減らしなさい\r\n",
    "タイトなジーンズにしなさい。太って見えることはありません。\r\n",
    "一言: 不適切\r\n",
    "今日だけは素直になりなさい。「本当に」思っていることを上司に言いなさい\r\n",
    "そのヘアスタイルは考え直した方が良いでしょう\r\n",
  };

  int listener_d = socket(PF_INET, SOCK_STREAM, 0); /* ソケットディスクリプタを生成 */

  /* bind(ポート30000) */
  struct sockaddr_in name;   /* sockaddr_in構造体 サーバーのIPアドレスやポート番号など保持する */
  name.sin_family = PF_INET; /* sin_family  プロトコルファミリ */
  name.sin_port = (in_port_t)htons(30000);  /* sin_port ポート番号 */
  name.sin_addr.s_addr = htonl(INADDR_ANY); /* sin_addr IPアドレス / */

  int reuse = 1; /* オプションを格納する */
  if (setsockopt(listener_d, SOL_SOCKET, SO_REUSEADDR, (char *)&reuse, sizeof(int)) == -1) {
    error("ソケットに再利用オプションを設定できません");
  }
  /*
   * setsockopt() ソケットのオプションの設定
   *   SOL_SOCKET   プロトコルレベル -> ソケットAPI 層でオプションを操作する
   *   SO_REUSEADDR オプション名     -> 使用中のアドレスにソケットをバインドできるようにする
  */

  if (bind(listener_d, (struct sockaddr *)&name, sizeof(name)) == -1) {
    error("ポートをバインドできません");
    /* ポートにバインドされたソケットはすぐに解除されない(30秒くらい) */
  }

  /* listen */
  listen(listener_d, 10);
  puts("接続を待っています");

  while (1) {
    /* accept */
    struct sockaddr_storage client_addr;
    unsigned int address_size = sizeof(client_addr);

    int connect_d = accept(listener_d, (struct sockaddr *)&client_addr, &address_size); /* 接続を受け入れる */
    char *msg = advice[rand() % 5];
    send(connect_d, msg, strlen(msg), 0); /* レスポンスを返す */

    close(connect_d);
  }

  return 0;
}
