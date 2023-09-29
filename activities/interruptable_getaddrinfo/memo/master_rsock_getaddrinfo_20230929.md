# `rsock_getaddrinfo`の実装

```c
struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
  struct rb_addrinfo* res = NULL; // 返り値を格納する
  struct addrinfo *ai; // 仮の返り値を格納する
  char *hostp, *portp; // ホスト名、ポート番号をchar*に格納する
  int error = 0;
  char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
  int additional_flags = 0;

  // ホスト名、ポート番号をVALUE -> 文字列へ変換した値をchar*に格納
  hostp = host_str(host, hbuf, sizeof(hbuf), &additional_flags);
  portp = port_str(port, pbuf, sizeof(pbuf), &additional_flags);

  if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
    hints->ai_socktype = SOCK_DGRAM;
  }
  hints->ai_flags |= additional_flags;

  // hostpにはIPアドレスとホスト名いずれかが格納されている
  error = numeric_getaddrinfo(hostp, portp, hints, &ai);
  // うまくいくとerrorは0、aiにはhostp, portpから変換したaddrinfoが格納されている

  if (error == 0) { // 最良ケース。このままreturnする
    res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    res->allocated_by_malloc = 1;
    res->ai = ai;
  } else {
    VALUE scheduler = rb_fiber_scheduler_current();
    int resolved = 0;

    if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
      error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

      if (error != EAI_FAIL) {
        resolved = 1;
      }
    }

    if (!resolved) {
#ifdef GETADDRINFO_EMU
      error = getaddrinfo(hostp, portp, hints, &ai);
#else
      struct getaddrinfo_arg arg;
      MEMZERO(&arg, struct getaddrinfo_arg, 1);
      arg.node = hostp;
      arg.service = portp;
      arg.hints = hints;
      arg.res = &ai;
      error = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);
#endif
      if (error == 0) {
        res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        res->allocated_by_malloc = 0;
        res->ai = ai;
      }
    }
  }

 if (error) {
   if (hostp && hostp[strlen(hostp)-1] == '\n') {
     rb_raise(rb_eSocket, "newline at the end of hostname");
   }
   rsock_raise_socket_error("getaddrinfo", error);
 }

 return res;
}
```

```c
// char*型のnode (ホスト名かIPアドレス) とservice (ポート番号) を受け取る
// nodeがIPアドレスフォーマット、かつserviceがポート番号としてパース可能ならaddrinfo**に変換して返す
// そうでない場合やHAVE_INET_PTONが未定義の場合はEAI_FAILを返す
static int
numeric_getaddrinfo(
  const char *node,
  const char *service,
  const struct addrinfo *hints,
  struct addrinfo **res
) {
#ifdef HAVE_INET_PTON
# if defined __MINGW64__
#   define inet_pton(f,s,d)        rb_w32_inet_pton(f,s,d)
# endif

  int port;

  // parse_numeric_port -> STRTOUL (ruby_strtoul)
  // ポート番号をintに変換した値をportに格納
  if (node && parse_numeric_port(service, &port)) {
    static const struct {
      int socktype;
      int protocol;
    } list[] = {
      { SOCK_STREAM, IPPROTO_TCP },
      { SOCK_DGRAM, IPPROTO_UDP },
      { SOCK_RAW, 0 }
    };

    struct addrinfo *ai = NULL; // 仮の返り値を格納する
    int hint_family = hints ? hints->ai_family : PF_UNSPEC;
    int hint_socktype = hints ? hints->ai_socktype : 0;
    int hint_protocol = hints ? hints->ai_protocol : 0;
    char ipv4addr[4];

#ifdef AF_INET6
     // IPv6対応しており、 IPv6アドレス解決する場合
    char ipv6addr[16];
    if (
      // アドレスファミリがPF_UNSPECもしくはPF_INET6
      // かつnodeがIPv6アドレスフォーマット
      // かつnodeをネットワークフォーマットに変換可能 (ついでにipv6addrに格納)
      (hint_family == PF_UNSPEC || hint_family == PF_INET6) &&
      strspn(node, "0123456789abcdefABCDEF.:") == strlen(node) &&
      inet_pton(AF_INET6, node, ipv6addr)
    ) {
      int i;
      for (i = numberof(list) - 1; 0 <= i; i--) {
        if (
          (hint_socktype == 0 || hint_socktype == list[i].socktype) &&
          (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)
        ) {
          struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
          struct sockaddr_in6 *sa = xmalloc(sizeof(struct sockaddr_in6));

          INIT_SOCKADDR_IN6(sa, sizeof(struct sockaddr_in6));
          // (saのsin_familyにAF_INET6を格納)
          // (saのsin_lenにlenを格納)
          // #define INIT_SOCKADDR_IN6(addr, len) \
          //   do { \
          //     struct sockaddr_in6 *init_sockaddr_ptr = (addr); \
          //     socklen_t init_sockaddr_len = (len); \
          //     memset(init_sockaddr_ptr, 0, init_sockaddr_len); \
          //     init_sockaddr_ptr->sin6_family = AF_INET6; \
          //     SET_SIN6_LEN(init_sockaddr_ptr, init_sockaddr_len); \
          //   } while (0)

          // ipv6addrをsaのsin6_addrにコピー
          memcpy(&sa->sin6_addr, ipv6addr, sizeof(ipv6addr));
          // portをネットワークバイトオーダーに変換してsaのsin_portへ格納
          sa->sin6_port = htons(port);

          ai0->ai_family = PF_INET6;
          ai0->ai_socktype = list[i].socktype;
          ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
          ai0->ai_addrlen = sizeof(struct sockaddr_in6);
          ai0->ai_addr = (struct sockaddr *)sa; // <- saをai0のai_addrとして格納
          ai0->ai_canonname = NULL;
          ai0->ai_next = ai;

          ai = ai0;
        }
      }
    }
  } else {

#endif // ifdef AF_INET6

    // IPv4アドレス解決する場合
    if (
      // アドレスファミリがPF_INET
      // かつnodeがIPv4アドレスフォーマット
      // かつnodeをネットワークフォーマットに変換可能 (ついでにipv4addrに格納)
      (hint_family == PF_UNSPEC || hint_family == PF_INET) &&
      strspn(node, "0123456789.") == strlen(node) &&
      inet_pton(AF_INET, node, ipv4addr)
    ) {
      int i;

      for (i = numberof(list)-1; 0 <= i; i--) {
        if (
          (hint_socktype == 0 || hint_socktype == list[i].socktype) &&
          (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)
        ) {
          struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
          struct sockaddr_in *sa = xmalloc(sizeof(struct sockaddr_in));

          INIT_SOCKADDR_IN(sa, sizeof(struct sockaddr_in));
          // (saのsin_familyにAF_INETを格納)
          // (saのsin_lenにlenを格納)
          // #define INIT_SOCKADDR_IN(addr, len) \
          //   do { \
          //     struct sockaddr_in *init_sockaddr_ptr = (addr); \
          //     socklen_t init_sockaddr_len = (len); \
          //     memset(init_sockaddr_ptr, 0, init_sockaddr_len); \
          //     init_sockaddr_ptr->sin_family = AF_INET; \
          //     SET_SIN_LEN(init_sockaddr_ptr, init_sockaddr_len); \
          //   } while (0)

          // ipv4addrをsaのsin_addrにコピー
          memcpy(&sa->sin_addr, ipv4addr, sizeof(ipv4addr));
          // portをネットワークバイトオーダーに変換してsaのsin_portへ格納
          sa->sin_port = htons(port);

          ai0->ai_family = PF_INET;
          ai0->ai_socktype = list[i].socktype;
          ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
          ai0->ai_addrlen = sizeof(struct sockaddr_in);
          ai0->ai_addr = (struct sockaddr *)sa; // <- saをai0のai_addrとして格納
          ai0->ai_canonname = NULL;
          ai0->ai_next = ai;

          ai = ai0;
        }
      }
    }

    if (ai) {
      *res = ai;
      return 0;
    }
  }
#endif // ifdef HAVE_INET_PTON
  // ホスト名が空、ポート番号をintに変換できない、
  // あるいはここまでで名前解決できなかった場合
  return EAI_FAIL;
}
```
