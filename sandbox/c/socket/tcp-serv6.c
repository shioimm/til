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
  int  flag = 1;
  char buf[32];
  char addrstr[INET6_ADDRSTRLEN];
  struct sockaddr_in6 addr;
  struct sockaddr_in6 client;
  socklen_t clen;

  sock0 = socket(AF_INET6, SOCK_STREAM, 0);

  if (setsockopt(sock0, IPPROTO_IPV6, IPV6_V6ONLY, (void *)&flag, sizeof(flag)) != 0) {
    perror("setsockopt failed");
    return 1;
  }

  // ホストの設定
  addr.sin6_family = AF_INET6;
  addr.sin6_port   = htons(54321); // ホストバイトオーダをネットワークバイトオーダに変換
  addr.sin6_addr   = in6addr_any;   // すべてのネットワークインターフェースで受け付ける

  if (bind(sock0, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
    perror("bind failed");
    return 1;
  }

  listen(sock0, 5);

  clen = sizeof(client);
  sock = accept(sock0, (struct sockaddr *)&client, &clen);

  // クライアントのIPv4アドレスを文字列に変換
  inet_ntop(AF_INET6, &client.sin6_addr, addrstr, sizeof(addrstr));
  printf("connection from : %s, port=%d\n", addrstr, ntohs(client.sin6_port));

  memset(buf, 0, sizeof(buf));
  n = read(sock, buf, sizeof(buf));
  printf("n=%d\nmessage : %s\n", n, buf);

  snprintf(buf, sizeof(buf), "message from IPv6 server");
  n = write(sock, buf, strnlen(buf, sizeof(buf)));

  close(sock);
  close(sock0);

  return 0;
}
