/*
 * 引用: Head First C
 * 第11章 ソケットとネットワーキング 3
*/

#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

int listener_d;

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int read_in(int socket, char *buf, int len)
{
  char *s = buf;
  int s_len = len;
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

int open_listener_socket()
{
  int s = socket(PF_INET, SOCK_STREAM, 0);

  if (s == -1) {
    error("ソケットを開けません");
  }

  return s;
}

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

int say(int socket, char *s)
{
  int result = send(socket, s, strlen(s), 0);

  if (result == -1) {
    fprintf(stderr, "%s: %s\n", "クライアントとの通信エラー", strerror(errno));
  }

  return result;
}

void handle_shutdown(int sig)
{
  if (listener_d) {
    close(listener_d);
  }

  fprintf(stderr, "さようなら！\n");
  exit(0);
}

int catch_signal(int sig, void (*handler)(int))
{
  struct sigaction action;
  action.sa_handler = handler;
  sigemptyset(&action.sa_mask);
  action.sa_flags = 0;
  return sigaction(sig, &action, NULL);
}

int main(int argc, char *argv[])
{
  if (catch_signal(SIGINT, handle_shutdown) == -1) {
    error("割り込みハンドラを設定できません");
  }

  listener_d = open_listener_socket();
  bind_to_port(listener_d, 30000);

  if (listen(listener_d, 10) == -1) {
    error("接続待ちできません");
  }

  struct sockaddr_storage client_addr;
  unsigned int adress_size = sizeof(client_addr);

  puts("接続を待っています");

  char buf[255];

  while (1) {
    int connect_d = accept(listener_d, (struct sockaddr *)&client_addr, &adress_size);

    if (connect_d == -1) {
      error("第二のソケットを開けません");
    }

    if (!fork()) { /* fork()は正常系で0 / 異常系で-1を返す */
      /* 以下は子プロセスの処理 */
      close(listener_d); /* 子プロセスではメインリスナーソケットを閉じる */

      if (say(connect_d, "インターネットノックノックサーバー\r\nver 1.0\r\nKnock! Knock!\r\n") != -1) {
        read_in(connect_d, buf, sizeof(buf));

        if (strncasecmp("Who's there?", buf, 12)) {
          say(connect_d, "「Who's there?」と入力しなければいけません！\r\n");
        } else {
          if (say(connect_d, "Oscar\r\n") != -1) {
            read_in(connect_d, buf, sizeof(buf));

            if (strncasecmp("Oscar who?", buf, 10)) {
              say(connect_d, "「Oscar who?」と入力しなければいけません！\r\n");
            } else {
              say(connect_d, "Oscar silly question. you get a silly answer\r\n");
            }
          }
        }
      }
      /* 子プロセスがクライアントとのソケットを閉じる */
      close(connect_d);
      /* 子プロセスはクライアントとのやりとりが終わったら終了する */
      exit(0);
      /* ここまで子プロセスの処理 */
    }
    close(connect_d);
  }

  return 0;
}
