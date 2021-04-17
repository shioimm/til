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
  int  sock0;
  int  sock;
  int  n;
  char buf[32];
  char addrstr[INET_ADDRSTRLEN];
  struct sockaddr_in addr;
  struct sockaddr_in client;
  socklen_t clen;

  sock0 = socket(AF_INET, SOCK_STREAM, 0);

  // ホストの設定
  addr.sin_family      = AF_INET;
  addr.sin_port        = htons(54321); // ホストバイトオーダをネットワークバイトオーダに変換
  addr.sin_addr.s_addr = INADDR_ANY;   // すべてのネットワークインターフェースで受け付ける

  if (bind(sock0, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
    perror("bind failed");
    return 1;
  }

  listen(sock0, 5);

  clen = sizeof(client);
  sock = accept(sock0, (struct sockaddr *)&client, &clen);

  // クライアントのIPv4アドレスを文字列に変換
  inet_ntop(AF_INET, &client.sin_addr, addrstr, sizeof(addrstr));
  printf("connection from : %s, port=%d\n", addrstr, ntohs(client.sin_port));

  memset(buf, 0, sizeof(buf));
  n = read(sock, buf, sizeof(buf));
  printf("n=%d\nmessage : %s\n", n, buf);

  snprintf(buf, sizeof(buf), "message from IPv4 server");
  n = write(sock, buf, strnlen(buf, sizeof(buf)));

  close(sock);
  close(sock0);

  return 0;
}
