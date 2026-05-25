#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <ares.h>

static void callback(void *arg, int status, int timeouts, struct ares_addrinfo *result)
{
    if (status != ARES_SUCCESS) {
      fprintf(stderr, "lookup failed: %s\n", ares_strerror(status));
      return;
    }

    printf("name: %s\n", result->name);

    for (struct ares_addrinfo_node *node = result->nodes; node; node = node->ai_next) {
      const void *addr = NULL;
      char abuf[INET6_ADDRSTRLEN];

      if (node->ai_family == AF_INET) {
          struct sockaddr_in *sa = (struct sockaddr_in *)node->ai_addr;
          addr = &sa->sin_addr;
      } else if (node->ai_family == AF_INET6) {
          struct sockaddr_in6 *sa = (struct sockaddr_in6 *)node->ai_addr;
          addr = &sa->sin6_addr;
      }

      if (ares_inet_ntop(node->ai_family, addr, abuf, sizeof(abuf)) != NULL) {
        printf("  address: %s\n", abuf);
      }
    }

    ares_freeaddrinfo(result);
}

int main(int _argc, char *_argv[])
{
    const char *hostname = "example.com";

    int status;
    ares_channel_t *channel = NULL; // 問い合わせを管理するチャネル

    struct ares_options options;
    int optmask = 0;
    memset(&options, 0, sizeof(options));
    options.evsys = ARES_EVSYS_DEFAULT;
    optmask |= ARES_OPT_EVENT_THREAD; // c-ares側のevent threadがイベントループを実行する

    // セッションの初期化 (/etc/resolv.confの読み込み)
    status = ares_library_init(ARES_LIB_INIT_ALL);

    if (status != ARES_SUCCESS) {
        fprintf(stderr, "ares_library_init failed: %s\n", ares_strerror(status));
        return 1;
    }

    status = ares_init_options(&channel, &options, optmask);

    if (status != ARES_SUCCESS) {
        fprintf(stderr, "ares_init_options failed: %s\n", ares_strerror(status));
        ares_library_cleanup();
        return 1;
    }

    struct ares_addrinfo_hints hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = 0;
    hints.ai_flags = ARES_AI_CANONNAME;

    // DNS問い合わせをchannelに登録、完了時にcallbackを実行
    ares_getaddrinfo(channel, hostname, NULL, &hints, callback, NULL);

    // 未完了の問い合わせがなくなるまで待機
    ares_queue_wait_empty(channel, -1);

    // channelに紐付いたソケット・メモリなどのリソースを解放
    ares_destroy(channel);

    // グローバルリソースの解放
    ares_library_cleanup();

    return 0;
}

// gcc ruby/dev/net/memo/c_ares/sample.c $(pkg-config --cflags --libs libcares) -o ruby/dev/net/memo/c_ares/sample && ruby/dev/net/memo/c_ares/sample
