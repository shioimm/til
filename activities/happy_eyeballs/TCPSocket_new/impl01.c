#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close
#include <netdb.h>     // addrinfo, getaddrinfo, freeaddrinfo
#include <pthread.h>

#define HOSTNAME "localhost"
#define SERVICE "9292"

struct address_resolver_data {
  struct addrinfo hints;
  struct addrinfo *initial_result;

  int *is_ipv6_resolved;
  int *is_ipv4_resolved;
  pthread_mutex_t *mutex;
};

struct addrinfo *next_addrinfo(struct addrinfo *res)
{
  if (res->ai_next) {
    return res->ai_next;
  } else {
    return NULL;
  }
}

void *address_resolver(void *arg)
{
  struct address_resolver_data *data = (struct address_resolver_data *)arg;
  char *hostname = HOSTNAME;
  char *service  = SERVICE;
  int err;

  if ((err = getaddrinfo(hostname, service, &data->hints, &data->initial_result)) != 0) {
    printf("hostname resolution error %d\n", err);
    pthread_exit(NULL);
  }

  if (data->hints.ai_family == PF_INET6) {
    pthread_mutex_lock(data->mutex);
    *data->is_ipv6_resolved = 1;
    pthread_mutex_unlock(data->mutex);
  } else {
    pthread_mutex_lock(data->mutex);
    *data->is_ipv4_resolved = 1;
    pthread_mutex_unlock(data->mutex);

    if (*data->is_ipv6_resolved == 0) usleep(50000); // Resolution Delay
  }

  return NULL;
}

int main()
{
  struct addrinfo *ipv4_result;
  struct addrinfo *ipv6_result;
  struct addrinfo *connecting_addrinfo;
  int sock;
  int last_connecting_family;
  int is_ipv4_initial_result_picked, is_ipv6_initial_result_picked = 0;
  pthread_t ipv6_resolv_thread, ipv4_resolv_thread;

  // アドレス解決スレッド関数に渡す引数の準備
  // TODO
  //   スレッド内から条件変数にsignalを送出できるようにする
  //   メインスレッドでアドレス解決を待機 (joinを消す)
  int is_ipv6_resolved, is_ipv4_resolved = 0;
  pthread_mutex_t mutex;
  pthread_mutex_init(&mutex, NULL);

  struct address_resolver_data ipv6_resolver_data, ipv4_resolver_data;

  memset(&ipv4_resolver_data.hints, 0, sizeof(ipv4_resolver_data.hints));
  ipv4_resolver_data.hints.ai_socktype = SOCK_STREAM;
  ipv4_resolver_data.hints.ai_family   = PF_INET;
  ipv4_resolver_data.is_ipv6_resolved  = &is_ipv6_resolved;
  ipv4_resolver_data.is_ipv4_resolved  = &is_ipv4_resolved;
  ipv4_resolver_data.mutex             = &mutex;

  memset(&ipv6_resolver_data.hints, 0, sizeof(ipv6_resolver_data.hints));
  ipv6_resolver_data.hints.ai_socktype = SOCK_STREAM;
  ipv6_resolver_data.hints.ai_family   = PF_INET6;
  ipv6_resolver_data.is_ipv6_resolved  = &is_ipv6_resolved;
  ipv6_resolver_data.is_ipv4_resolved  = &is_ipv4_resolved;
  ipv6_resolver_data.mutex             = &mutex;

  if (pthread_create(&ipv6_resolv_thread, NULL, address_resolver, &ipv6_resolver_data) != 0) {
    printf("Error: Failed to create new rsolver thread.\n");
    exit(1);
  }

  if (pthread_create(&ipv4_resolv_thread, NULL, address_resolver, &ipv4_resolver_data) != 0) {
    printf("Error: Failed to create new rsolver thread.\n");
    exit(1);
  }

  // FIXME joinしてしまうと実行が終わるまで待ってしまうので、最終的にはkillする必要あり
  pthread_join(ipv6_resolv_thread, NULL);
  pthread_join(ipv4_resolv_thread, NULL);
  pthread_mutex_destroy(&mutex);

  ipv4_result = ipv4_resolver_data.initial_result;
  ipv6_result = ipv6_resolver_data.initial_result;

  while (1) {
    // TODO pthread_cond_waitする

    if (is_ipv6_resolved && !is_ipv6_initial_result_picked) {
      connecting_addrinfo = ipv6_result;
      is_ipv6_initial_result_picked = 1;
    }
    if (is_ipv4_resolved && !is_ipv4_initial_result_picked) {
      connecting_addrinfo = ipv4_result;
      is_ipv4_initial_result_picked = 1;
    }

    sock = socket(connecting_addrinfo->ai_family,
                  connecting_addrinfo->ai_socktype,
                  connecting_addrinfo->ai_protocol);

    if (sock < 0) continue;

    last_connecting_family = connecting_addrinfo->ai_family;

    if (connect(sock, connecting_addrinfo->ai_addr, connecting_addrinfo->ai_addrlen) != 0) {
      close(sock);

      switch (last_connecting_family) {
        case PF_INET6:
          connecting_addrinfo = next_addrinfo(ipv4_result);
          ipv4_result = connecting_addrinfo;
          break;
        case PF_INET:
          connecting_addrinfo = next_addrinfo(ipv6_result);
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

  freeaddrinfo(ipv4_resolver_data.initial_result);
  freeaddrinfo(ipv6_resolver_data.initial_result);

  char buf[1024];

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(sock, buf, sizeof(buf));
  printf("%s", buf);

  close(sock);

  return 0;
}
