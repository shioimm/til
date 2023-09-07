#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close
#include <netdb.h>     // addrinfo, getaddrinfo, freeaddrinfo

struct addrinfo *next_addrinfo(struct addrinfo *res)
{
  if (res->ai_next) {
    return res->ai_next;
  } else {
    return NULL;
  }
}

int main()
{
  char *hostname = "localhost";
  char *service  = "9292";
  struct addrinfo ipv4_hints, *ipv4_initial_result, *ipv4_result;
  struct addrinfo ipv6_hints, *ipv6_initial_result, *ipv6_result;
  struct addrinfo *connecting_addrinfo;
  int ipv4_err, ipv6_err;
  int sock;
  int last_connecting_family;
  int is_ipv4_initial_result_picked, is_ipv6_initial_result_picked = 0;

  memset(&ipv4_hints, 0, sizeof(ipv4_hints));
  ipv4_hints.ai_socktype = SOCK_STREAM;
  ipv4_hints.ai_family = PF_INET;

  if ((ipv4_err = getaddrinfo(hostname, service, &ipv4_hints, &ipv4_initial_result)) != 0) {
    printf("hostname resolution error (A) %d\n", ipv4_err);
    return 1;
  }

  memset(&ipv6_hints, 0, sizeof(ipv6_hints));
  ipv6_hints.ai_socktype = SOCK_STREAM;
  ipv6_hints.ai_family = PF_INET6;

  if ((ipv6_err = getaddrinfo(hostname, service, &ipv6_hints, &ipv6_initial_result)) != 0) {
    printf("hostname resolution error (AAAA) %d\n", ipv6_err);
    return 1;
  }

  ipv4_result = ipv4_initial_result;
  ipv6_result = ipv6_initial_result;

  connecting_addrinfo = ipv6_result;
  is_ipv6_initial_result_picked = 1;

  while (1) {
    sock = socket(connecting_addrinfo->ai_family,
                  connecting_addrinfo->ai_socktype,
                  connecting_addrinfo->ai_protocol);

    if (sock < 0) continue;

    last_connecting_family = connecting_addrinfo->ai_family;

    if (connect(sock, connecting_addrinfo->ai_addr, connecting_addrinfo->ai_addrlen) != 0) {
      close(sock);

      switch (last_connecting_family) {
        case PF_INET6:
          if (is_ipv4_initial_result_picked) {
            connecting_addrinfo = next_addrinfo(ipv4_result);
          } else {
            connecting_addrinfo = ipv4_result;
            is_ipv4_initial_result_picked = 1;
          }
          ipv4_result = connecting_addrinfo;
          break;
        case PF_INET:
          if (is_ipv6_initial_result_picked) {
            connecting_addrinfo = next_addrinfo(ipv6_result);
          } else {
            connecting_addrinfo = ipv6_result;
            is_ipv6_initial_result_picked = 1;
          }
          ipv6_result = connecting_addrinfo;
          break;
      }

      if (connecting_addrinfo == NULL) {
        printf("failed to connect\n");
        return 1;
      } else {
        continue;
      }
    }

    break; // 接続に成功
  }

  freeaddrinfo(ipv4_initial_result);
  freeaddrinfo(ipv6_initial_result);

  char buf[1024];

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(sock, buf, sizeof(buf));
  printf("%s", buf);

  close(sock);

  return 0;
}
