#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close
#include <netdb.h>     // addrinfo, getaddrinfo, freeaddrinfo
#include <pthread.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/select.h>
#include <errno.h>

#define CONNECTION_ATTEMPT_DELAY_USEC 250000

#define HOSTNAME "localhost"
#define SERVICE "9292"

struct address_resolver_data {
  struct addrinfo hints;
  struct addrinfo *initial_result;

  int *is_ipv6_resolved;
  int *is_ipv4_resolved;
  int *resolv_last_error;
  pthread_mutex_t *mutex;
  pthread_cond_t  *cond;
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
    *data->resolv_last_error = errno;
    pthread_exit(NULL);
  }

  if (data->hints.ai_family == PF_INET6) {
    pthread_mutex_lock(data->mutex);
    *data->is_ipv6_resolved = 1;
    pthread_cond_signal(data->cond);
    pthread_mutex_unlock(data->mutex);
  } else {
    pthread_mutex_lock(data->mutex);
    *data->is_ipv4_resolved = 1;
    pthread_cond_signal(data->cond);
    pthread_mutex_unlock(data->mutex);

    if (*data->is_ipv6_resolved == 0) usleep(50000); // Resolution Delay
  }

  return NULL;
}

void prepare_writefds(fd_set *writefds, int *connecting_sockets, int connecting_sockets_size)
{
  FD_ZERO(writefds);
  for (int i = 0; i < connecting_sockets_size; i++) {
    if (connecting_sockets[i] > 0) {
      FD_SET(connecting_sockets[i], writefds);
    }
  }
}

int max_connecting_socket_fds(int *connecting_sockets, int connecting_sockets_size)
{
  int value = connecting_sockets[0];

  for (int i = 0; i < connecting_sockets_size; i++) {
    if (connecting_sockets[i] > value) {
      value = connecting_sockets[i];
    }
  }

  return value;
}

int main()
{
  struct addrinfo *ipv4_result, *ipv6_result, *connecting_addrinfo, *last_attempted_addrinfo;
  int connected_socket = 0;
  int is_ipv4_initial_result_picked = 0;
  int is_ipv6_initial_result_picked = 0;
  int resolv_last_error = 0;
  pthread_t ipv6_resolv_thread, ipv4_resolv_thread;

  // アドレス解決
  int is_ipv6_resolved, is_ipv4_resolved = 0;
  pthread_mutex_t mutex;
  pthread_mutex_init(&mutex, NULL);
  pthread_cond_t cond;
  pthread_cond_init(&cond, NULL);

  struct address_resolver_data ipv6_resolver_data, ipv4_resolver_data;

  memset(&ipv4_resolver_data.hints, 0, sizeof(ipv4_resolver_data.hints));
  ipv4_resolver_data.hints.ai_socktype = SOCK_STREAM;
  ipv4_resolver_data.hints.ai_family   = PF_INET;
  ipv4_resolver_data.is_ipv6_resolved  = &is_ipv6_resolved;
  ipv4_resolver_data.is_ipv4_resolved  = &is_ipv4_resolved;
  ipv4_resolver_data.resolv_last_error = &resolv_last_error;
  ipv4_resolver_data.mutex             = &mutex;
  ipv4_resolver_data.cond              = &cond;

  memset(&ipv6_resolver_data.hints, 0, sizeof(ipv6_resolver_data.hints));
  ipv6_resolver_data.hints.ai_socktype = SOCK_STREAM;
  ipv6_resolver_data.hints.ai_family   = PF_INET6;
  ipv6_resolver_data.is_ipv6_resolved  = &is_ipv6_resolved;
  ipv6_resolver_data.is_ipv4_resolved  = &is_ipv4_resolved;
  ipv6_resolver_data.resolv_last_error = &resolv_last_error;
  ipv6_resolver_data.mutex             = &mutex;
  ipv6_resolver_data.cond              = &cond;

  if (pthread_create(&ipv6_resolv_thread, NULL, address_resolver, &ipv6_resolver_data) != 0) {
    printf("Error: Failed to create new rsolver thread.\n");
    exit(1);
  }

  if (pthread_create(&ipv4_resolv_thread, NULL, address_resolver, &ipv4_resolver_data) != 0) {
    printf("Error: Failed to create new rsolver thread.\n");
    exit(1);
  }

  // 接続試行
  struct timeval connection_attempt_delay;
  connection_attempt_delay.tv_sec = 0;
  connection_attempt_delay.tv_usec = CONNECTION_ATTEMPT_DELAY_USEC;
  int connecting_sockets[2] = {0, 0}; // てきとう
  int connecting_sockets_cursor = 0;
  int connecting_sockets_size = sizeof(connecting_sockets) / sizeof(connecting_sockets[0]);
  int connention_last_error = 0;

  while (1) {
    if ((!is_ipv6_resolved && !is_ipv4_resolved) ||
        (last_attempted_addrinfo != NULL &&
         (is_ipv4_resolved && !is_ipv6_resolved) ||
         (is_ipv6_resolved && !is_ipv4_resolved))) {
      pthread_mutex_lock(&mutex);
      if (pthread_cond_wait(&cond, &mutex) != 0) {
        perror("pthread_cond_wait(3)");
        exit(1);
      }
      pthread_mutex_unlock(&mutex);
    }

    // 最初のループで使用するアドレスを選択
    if (is_ipv6_resolved && !is_ipv6_initial_result_picked) {
      pthread_join(ipv6_resolv_thread, NULL);

      ipv6_result = ipv6_resolver_data.initial_result;
      connecting_addrinfo = ipv6_result;
      is_ipv6_initial_result_picked = 1;
    } else if (is_ipv4_resolved && !is_ipv4_initial_result_picked) {
      pthread_join(ipv4_resolv_thread, NULL);

      ipv4_result = ipv4_resolver_data.initial_result;
      connecting_addrinfo = ipv4_result;
      is_ipv4_initial_result_picked = 1;
    }

    if (connecting_addrinfo == NULL && connecting_sockets[0] > 0) {
      // アドレス在庫が枯渇しており、接続中のソケットがある場合
      int ret;
      fd_set writefds;
      prepare_writefds(&writefds, connecting_sockets, connecting_sockets_size);

      int connecting_sockets_max = max_connecting_socket_fds(connecting_sockets, connecting_sockets_size);
      // TODO 第四引数にconnect_timeoutをアサインする
      ret = select(connecting_sockets_max + 1, NULL, &writefds, NULL, NULL);

      if (ret < 0) {
        for (int i = 0; i < connecting_sockets_size; i++) {
          close(connecting_sockets[i]);
        }
        perror("select(2)");
        return -1; // select(2) に失敗
      } else if (ret > 0) {
        for (int i = 0; i < connecting_sockets_size; i++) {
          int error;
          socklen_t len = (socklen_t)sizeof(error);
          getsockopt(connecting_sockets[i], SOL_SOCKET, SO_ERROR, (void *)&error, &len);

          if (error == 0) {
            // 接続に成功
            connected_socket = connecting_sockets[i];
            break;
          } else if (error == EINPROGRESS) {
            // 接続中
          } else {
            // 接続に失敗
            for (int i = 0; i < connecting_sockets_size; i++) {
              close(connecting_sockets[i]);
            }
            perror("select(2)");
            return -1; // select(2) に失敗
          }
        }
        if (connected_socket) break; // 接続に成功
      } else if (ret == 0) {
        // connect_timeoutまでに名前解決できなかった場合
        printf("connect_timeout\n");
        return -1;
      }
    } else if (connecting_addrinfo == NULL && connention_last_error) {
      // アドレス在庫が枯渇しており、全てのソケットの接続に失敗している場合
      fprintf(stderr, "connection failed: %s\n", strerror(connention_last_error));
      return -1;
    } else if (connecting_addrinfo == NULL && resolv_last_error) {
      // 名前解決中にエラーが発生した場合
      if (is_ipv6_resolved && is_ipv4_resolved &&
          (resolv_last_error != EAI_ADDRFAMILY && resolv_last_error != EAI_AGAIN)) {
        fprintf(stderr, "hostname resolution failed: %s\n", strerror(resolv_last_error));
        return -1;
      } else {
        continue;
      }
    } else if (connecting_addrinfo == NULL) {
      printf("resolv_timeout\n");
      return -1;
    }

    int sock;
    sock = socket(connecting_addrinfo->ai_family,
                  connecting_addrinfo->ai_socktype,
                  connecting_addrinfo->ai_protocol);

    if (sock < 0) continue;

    // ソケットをノンブロッキングモードにセット
    int flags;
    flags = fcntl(sock, F_GETFL,0);
    fcntl(sock, F_SETFL, flags | O_NONBLOCK);

    last_attempted_addrinfo = connecting_addrinfo;

    if (connect(sock, connecting_addrinfo->ai_addr, connecting_addrinfo->ai_addrlen) == 0) {
      break; // 接続に成功
    }

    if (EINPROGRESS == errno) { // 接続中
      connecting_sockets[connecting_sockets_cursor] = sock;
      connecting_sockets_cursor++;

      int ret;
      fd_set writefds;
      prepare_writefds(&writefds, connecting_sockets, connecting_sockets_size);

      // EINPROGRESS時の動作検証用
      fd_set readfds;
      prepare_writefds(&readfds, connecting_sockets, connecting_sockets_size);

      int connecting_sockets_max = max_connecting_socket_fds(connecting_sockets, connecting_sockets_size);
      //ret = select(connecting_sockets_max + 1, NULL, &writefds, NULL, &connection_attempt_delay);

      // INPROGRESS時の動作検証用
      ret = select(connecting_sockets_max + 1, &readfds, NULL, NULL, &connection_attempt_delay);

      if (ret < 0) {
        for (int i = 0; i < connecting_sockets_size; i++) {
          close(connecting_sockets[i]);
        }
        perror("select(2)");
        return -1; // select(2) に失敗
      } else if (ret > 0) {
        connected_socket = sock;
        break; // 接続に成功
      } else if (ret == 0) {
        // タイムアウト。次のループへ
      }
    } else {
      // それ以外の接続エラー。次のループへ
      connention_last_error = errno;
      close(sock);
    }

    if (is_ipv6_resolved && !is_ipv6_initial_result_picked) {
      pthread_join(ipv6_resolv_thread, NULL);

      ipv6_result = ipv6_resolver_data.initial_result;
      connecting_addrinfo = ipv6_result;
      is_ipv6_initial_result_picked = 1;
    } else if (is_ipv4_resolved && !is_ipv4_initial_result_picked) {
      pthread_join(ipv4_resolv_thread, NULL);

      ipv4_result = ipv4_resolver_data.initial_result;
      connecting_addrinfo = ipv4_result;
      is_ipv4_initial_result_picked = 1;
    }

    // 次のループで使用するアドレスを選択
    if (last_attempted_addrinfo->ai_family == PF_INET6) {
      // IPv4アドレス解決が終わっておらず、かつIPv6アドレス在庫が枯渇している場合は次のループへスキップ
      if (!is_ipv4_resolved && last_attempted_addrinfo->ai_next == NULL) continue;

      if (!is_ipv4_resolved && last_attempted_addrinfo->ai_next != NULL) {
        connecting_addrinfo = last_attempted_addrinfo->ai_next;
        ipv6_result = connecting_addrinfo;
      } else if (is_ipv4_resolved && is_ipv4_initial_result_picked) {
        connecting_addrinfo = next_addrinfo(ipv4_result);
        ipv4_result = connecting_addrinfo;
      } else if (is_ipv4_resolved) {
        ipv4_result = ipv4_resolver_data.initial_result;
        connecting_addrinfo = ipv4_result;
        is_ipv4_initial_result_picked = 1;
      } else if (!is_ipv4_resolved && !is_ipv4_initial_result_picked) {
        pthread_join(ipv4_resolv_thread, NULL);

        ipv4_result = ipv4_resolver_data.initial_result;
        connecting_addrinfo = ipv4_result;
        is_ipv4_initial_result_picked = 1;
      }
    } else if (last_attempted_addrinfo->ai_family == PF_INET) {
      // IPv6アドレス解決が終わっておらず、かつIPv4アドレス在庫が枯渇している場合は次のループへスキップ
      if (!is_ipv6_resolved && last_attempted_addrinfo->ai_next == NULL) continue;

      if (!is_ipv6_resolved && last_attempted_addrinfo->ai_next != NULL) {
        connecting_addrinfo = last_attempted_addrinfo->ai_next;
        ipv4_result = connecting_addrinfo;
      } else if (is_ipv6_resolved && is_ipv6_initial_result_picked) {
        connecting_addrinfo = next_addrinfo(ipv6_result);
        ipv6_result = connecting_addrinfo;
      } else if (is_ipv6_resolved) {
        ipv6_result = ipv4_resolver_data.initial_result;
        connecting_addrinfo = ipv6_result;
        is_ipv6_initial_result_picked = 1;
      } else if (!is_ipv6_resolved && !is_ipv6_initial_result_picked) {
        pthread_join(ipv6_resolv_thread, NULL);

        ipv6_result = ipv6_resolver_data.initial_result;
        connecting_addrinfo = ipv6_result;
        is_ipv6_initial_result_picked = 1;
      }
    } else {
      printf("failed to connect\n");
      return -1;
    }
  }

  freeaddrinfo(ipv4_resolver_data.initial_result);
  freeaddrinfo(ipv6_resolver_data.initial_result);

  if (!is_ipv6_resolved) {
    pthread_cancel(ipv6_resolv_thread);
    pthread_join(ipv6_resolv_thread, NULL);
  }
  if (!is_ipv4_resolved) {
    pthread_cancel(ipv4_resolv_thread);
    pthread_join(ipv4_resolv_thread, NULL);
  }
  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);

  for (int i = 0; i < connecting_sockets_size; i++) {
    if (connecting_sockets[i] != connected_socket) {
      close(connecting_sockets[i]);
    }
  }

  int flags;
  flags = fcntl(connected_socket, F_GETFL,0);
  flags = flags & ~(flags & O_NONBLOCK);
  fcntl(connected_socket, F_SETFL, flags);

  char buf[1024];

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(connected_socket, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(connected_socket, buf, sizeof(buf));
  printf("%s", buf);
  close(connected_socket);

  return 0;
}
