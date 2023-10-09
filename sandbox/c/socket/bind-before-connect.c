// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main()
{
  struct sockaddr_in dest;
  struct sockaddr_in me;
  int  sock;
  char buf[32];
  int  n;

  sock = socket(AF_INET, SOCK_STREAM, 0);

  // 接続先の設定
  dest.sin_family = AF_INET;
  dest.sin_port   = htons(54321); // ホストバイトオーダをネットワークバイトオーダに変換

  // 文字列表現されたIPv4アドレスを32ビットの値に変換
  inet_pton(AF_INET, "127.0.0.1", &dest.sin_addr.s_addr);

  memset(&me, 0, sizeof(me));
  me.sin_family = AF_INET;
  me.sin_port   = htons(65432);
  if (bind(sock, (struct sockaddr *)&me, sizeof(me)) != 0) {
    perror("bind failed");
    return 1;
  }

  if (connect(sock, (struct sockaddr *)&dest, sizeof(dest)) != 0) {
    perror("connect failed");
    return 1;
  }

  snprintf(buf, sizeof(buf), "message from IPv4 client");
  n = write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  n = read(sock, buf, sizeof(buf));

  printf("n=%d, %s\n", n, buf);

  close(sock);

  return 0;
}
