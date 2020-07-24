/*
 * 引用: Head First C
 * 第11章 ソケットとネットワーキング 2
*/

#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>

/*
 * error()
 *   エラーメッセージを出力し、プロセスを終了させる
*/
void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

/*
 * read_in()
 *   クライアントからの入力をrecv()で受け取り、
 *   '\n'に達するまでの文字列を指定された配列に格納した後
 *   '\0'で文字列を終端させる
*/
int read_in(int socket, char *buf, int len)
{
  char *s = buf;
  int slen = len;
  int c = recv(socket, s, s_len, 0);

  while ((c > 0) && (s[c - 1] != '\n')) {
    s += c;
    s_len -= c;
    c = recv(socket, s, s_len, 0);
  }

  if (c < 0) {
    return c;
  } else if (c == 0) {
    buf[0] = '\0';
  } else {
    s[c - 1] = '\0';
  }

  return len - s_len;
}

/*
 * open_listener_socket()
 *   インターネットソケットストリーミングを作成
*/
int open_listener_socket()
{
  int s = socket(PF_INET, SOCK_STREAM, 0);

  if (s == -1) {
    error("ソケットを開けません");
  }

  return 0;
}

/*
 * bind_to_port()
 *   ソケットをポートにバインドする
*/
void bind_to_port(int socket, int port)
{
  struct sockaddr_in name;
  name.sin_family = PF_INET;
  name.sin_port = (in_port_t)htons(port);
  name.sin_addr.s_addr = htonl(INADDR_ANY);

  int reuse = 1;

  if (setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, (char *)&reuse, sizeof(int)) == -1) {
    error("ソケットに再利用オプションを設定できません");
  }

  int c = bind(socket, (struct sockaddr *)&name, sizeof(name));

  if (c == -1) {
    error("ポートをバインドできません");
  }
}

/*
 * say()
 *   クライアントにレスポンスを返す
*/
int say(int socket, char *s)
{
  int result = send(socket, s, strlen(s), 0);

  if (result == -1) {
    fprintf(stderr, "%s: %s\n", "クライアントとの通信エラー", strerror(errno));
  }

  return result;
}
