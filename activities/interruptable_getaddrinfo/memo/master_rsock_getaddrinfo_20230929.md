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
  // うまくいくとerrorは0、aiにはhostpとportpから変換したaddrinfoが格納されている

  if (error == 0) { // 最良ケース。このままreturnする
    res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    res->allocated_by_malloc = 1;
    res->ai = ai;
  } else {
    VALUE scheduler = rb_fiber_scheduler_current();
    //  (scheduler.c)
    //  VALUE
    //  rb_fiber_scheduler_current(void)
    //  {
    //    return rb_fiber_scheduler_current_for_threadptr(GET_THREAD());
    //  }
    //
    // static VALUE
    // rb_fiber_scheduler_current_for_threadptr(rb_thread_t *thread)
    // {
    //   VM_ASSERT(thread);
    //
    //   if (thread->blocking == 0) {
    //     return thread->scheduler;
    //   } else {
    //     return Qnil;
    //   }
    // }

    int resolved = 0;

    if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
      error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

      if (error != EAI_FAIL) {
        resolved = 1;
      }
    }

    // scheduler が設定されていない場合
    if (!resolved) {
#ifdef GETADDRINFO_EMU
      // 実際のgetaddrinfo(3)を実行
      // 成功するとerrorに0、aiには名前解決したaddrinfoが格納される
      error = getaddrinfo(hostp, portp, hints, &ai);
#else
      struct getaddrinfo_arg arg;
      // struct getaddrinfo_arg
      // {
      //   const char *node;
      //   const char *service;
      //   const struct addrinfo *hints;
      //   struct addrinfo **res;
      // };

      MEMZERO(&arg, struct getaddrinfo_arg, 1);
      // (internal/memory.h)
      //   #define MEMZERO(p,type,n) memset((p), 0, rbimpl_size_mul_or_raise(sizeof(type), (n)))

      arg.node = hostp;    // ホスト名
      arg.service = portp; // ポート番号
      arg.hints = hints;
      arg.res = &ai;       // 解決したaddrinfo

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

```c
// schedulerが空の場合は呼ばれない
static int
rb_scheduler_getaddrinfo(
  VALUE scheduler,
  VALUE host,
  const char *service, // ポート番号
  const struct addrinfo *hints,
  struct rb_addrinfo **res
) {
  int error, res_allocated = 0, _additional_flags = 0;
  long i, len;
  struct addrinfo *ai, *ai_tail = NULL;
  char *hostp;
  char _hbuf[NI_MAXHOST];
  VALUE ip_addresses_array, ip_address;

  ip_addresses_array = rb_fiber_scheduler_address_resolve(scheduler, host);

  if (ip_addresses_array == Qundef) {
    // Returns EAI_FAIL if the scheduler hook is not implemented:
    return EAI_FAIL;
  } else if (ip_addresses_array == Qnil) {
    len = 0;
  } else {
    len = RARRAY_LEN(ip_addresses_array);
  }

  for(i=0; i<len; i++) {
    ip_address = rb_ary_entry(ip_addresses_array, i);
    hostp = host_str(ip_address, _hbuf, sizeof(_hbuf), &_additional_flags);
    error = numeric_getaddrinfo(hostp, service, hints, &ai);

    if (error == 0) {
      if (!res_allocated) {
        res_allocated = 1;
        *res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        (*res)->allocated_by_malloc = 1;
        (*res)->ai = ai;
        ai_tail = ai;
      } else {
        while (ai_tail->ai_next) {
          ai_tail = ai_tail->ai_next;
        }
        ai_tail->ai_next = ai;
        ai_tail = ai;
      }
    }
  }

  if (res_allocated) { // At least one valid result.
    return 0;
  } else {
    return EAI_NONAME;
  }
}
```

```c
// thread.c
// * rb_thread_call_without_gvl - 同時実行/並列実行を許可する関数
//   (1) 割り込みをチェック
//   (2) GVLを解放する (他のRubyスレッドが並列に実行される可能性あり)
//   (3) data1でfunc()を呼び出す
//   (4) GVLを獲得する (他のRubyスレッドが並列実行できなくなる)
//   (5) 割り込みをチェック
//
//   割り込みチェックでは、非同期割り込みイベントをチェックし、対応する手続きを呼び出す。
//     (非同期割り込みイベント: Thread#kill、シグナルの送出, VMのシャットダウン要求など)
//     (対応する手続き: シグナルの場合は `trap'、Thread#raiseの場合は例外を発生させる)
//
//   GVLを解放した後、他のスレッドがこのスレッドに割り込んだ場合、
//   キャンセルフラグを切り替えたり、func()内での呼び出しを取り消しするなどして
//   func()の実行を中断するための関数であるubf() (un-blocking function) を呼び出す。
//   組み込みのubf()がfunc()を正しく割り込むことは保証されていない。
//   適切なubf()を指定しないと、プログラムは Control+C その他のシャットダウンイベントで停止しない。
//
//   IO処理を行う直前または最中に割り込みが発生した場合、ubf()はその関数呼び出しをキャンセルし、割り込みをチェックする
//   IO処理後に割り込みが発生した場合、処理が完了した後に割り込みをチェックすると、取得したデータが消えてしまう副作用が発生する場合がある

void *
rb_thread_call_without_gvl(
  void *(*func)(void *data),
  void *data1,
  rb_unblock_function_t *ubf,
  void *data2
) {
  return rb_nogvl(
    func,  // -> nogvl_getaddrinfo
    data1, // -> &arg (struct getaddrinfo_arg)
    ubf,   // -> RUBY_UBF_IO (IO操作用の組み込みubf)
    data2, // -> 0
    0
  );
}

void *
rb_nogvl(
  void *(*func)(void *),
  void *data1,
  rb_unblock_function_t *ubf,
  void *data2,
  int flags
) {
  void *val = 0;
  rb_execution_context_t *ec = GET_EC();
  rb_thread_t *th = rb_ec_thread_ptr(ec);
  rb_vm_t *vm = rb_ec_vm_ptr(ec);
  bool is_main_thread = vm->ractor.main_thread == th;
  int saved_errno = 0;
  VALUE ubf_th = Qfalse;

  if ((ubf == RUBY_UBF_IO) || (ubf == RUBY_UBF_PROCESS)) {
    ubf = ubf_select;
    data2 = th;
  } else if (ubf && rb_ractor_living_thread_num(th->ractor) == 1 && is_main_thread) {
    if (flags & RB_NOGVL_UBF_ASYNC_SAFE) {
      vm->ubf_async_safe = 1;
    } else {
      ubf_th = rb_thread_start_unblock_thread();
    }
  }

  BLOCKING_REGION(
    th,
    {
      val = func(data1);
      saved_errno = errno;
    },
    ubf,
    data2,
    flags & RB_NOGVL_INTR_FAIL
  );

  if (is_main_thread) vm->ubf_async_safe = 0;

  if ((flags & RB_NOGVL_INTR_FAIL) == 0) {
    RUBY_VM_CHECK_INTS_BLOCKING(ec);
  }

  if (ubf_th != Qfalse) {
    thread_value(rb_thread_kill(ubf_th));
  }

  errno = saved_errno;

  return val;
}
```

```c
static void *
nogvl_getaddrinfo(void *arg)
{
  // WIP
  int ret;
  struct getaddrinfo_arg *ptr = arg;
  ret = getaddrinfo(ptr->node, ptr->service, ptr->hints, ptr->res);
#ifdef __linux__
  /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
   * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
   */
  if (ret == EAI_SYSTEM && errno == ENOENT) {
    ret = EAI_NONAME;
  }
#endif
  return (void *)(VALUE)ret;
}
```