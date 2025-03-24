# interruptible-getaddrinfo.patchの実装
https://gist.github.com/mame/872d530cc1a83169370f9d95afcd299c

```c
struct getaddrinfo_arg
{
  const char *node;
  const char *service;
  const struct addrinfo *hints;
  struct addrinfo **res;

   // 追加
  int done, ret, refcount;
  rb_nativethread_lock_t mutex;
  rb_nativethread_cond_t cond;
};
```

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

    int resolved = 0;

    if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
      error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

      if (error != EAI_FAIL) {
        resolved = 1;
      }
    }

    // scheduler が設定されていない場合
    if (!resolved) {
#ifdef GETADDRINFO_EMU // (ext/socket/extconf.rb) enable_config("wide-getaddrinfo") ならここ
      error = getaddrinfo(hostp, portp, hints, &ai);
#else // 通常はこっち
      struct getaddrinfo_arg arg;
      MEMZERO(&arg, struct getaddrinfo_arg, 1);

      arg.node = hostp;    // ホスト名
      arg.service = portp; // ポート番号
      arg.hints = hints;
      arg.res = &ai;       // 解決したaddrinfoを格納するアドレス

      // 以下変更
      //   変更前: error = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);
      arg.done = 0;
      arg.ret = 0;
      arg.refcount = 2; // アドレスファミリの数
      rb_native_mutex_initialize(&arg.mutex); // mutexを初期化
      rb_native_cond_initialize(&arg.cond);   // 条件変数を初期化

      pthread_t t;
      // TODO: support win32
      // 生成したスレッドでdo_getaddrinfoを実行
      if (pthread_create(&t, 0, do_getaddrinfo, &arg) != 0) {
        error = EAGAIN;
      } else {
        // pthread_createに成功
        pthread_detach(t); // 実行中のスレッドをデタッチ状態にする
        error = (int)rb_ensure(wait_getaddrinfo, (VALUE)&arg, finish_getaddrinfo, (VALUE)&arg);
      }

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
// 変更前: nogvl_getaddrinfo() -> 変更後: do_getaddrinfo()
static void *
do_getaddrinfo(void *arg)
{
  // ここは生成したスレッドの中
  int ret;
  struct getaddrinfo_arg *ptr = arg;

  // ptr->resにaddrinfoを格納
  // このret返してない気がする...
  ret = getaddrinfo(ptr->node, ptr->service, ptr->hints, ptr->res);

#ifdef __linux__
  /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
   * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
   */
  if (ret == EAI_SYSTEM && errno == ENOENT) {
    ret = EAI_NONAME;
  }
#endif

  // 以下変更
  //   変更前: return (void *)(VALUE)ret;
  rb_native_mutex_lock(&ptr->mutex);
  ptr->done = 1;
  pthread_cond_signal(&ptr->cond);

  if (0 == --ptr->refcount) { // refcountをデクリメントした値が0: これ以上解決するアドレスファミリがない場合
    rb_native_mutex_unlock(&ptr->mutex);
    rb_native_cond_destroy(&ptr->cond);   // 条件変数を削除
    rb_native_mutex_destroy(&ptr->mutex); // mutexを削除
  } else { // 未解決のアドレスファミリが残っている場合
    rb_native_mutex_unlock(&ptr->mutex);
  }
  return 0;
}
```

```c
static VALUE
wait_getaddrinfo(VALUE arg)
{
  // ここはcond_signal待ちのメインスレッド
  void *ptr = (void *)arg;

  // GVLを解放してwait_getaddrinfo0()を実行する
  // wait_getaddrinfo0()の実行結果を返す
  // 割り込み時はcancel_getaddrinfo()を呼ぶ
  return (VALUE)rb_thread_call_without_gvl(wait_getaddrinfo0, ptr, cancel_getaddrinfo, ptr);
}

static void *
wait_getaddrinfo0(void *arg)
{
  // ここはcond_signal待ちのメインスレッド
  struct getaddrinfo_arg *ptr = arg;
  rb_native_mutex_lock(&ptr->mutex);

  // 名前解決スレッドがptr->doneを更新するまで待機
  while (!ptr->done) {
    rb_native_cond_wait(&ptr->cond, &ptr->mutex);
  }

  rb_native_mutex_unlock(&ptr->mutex);
  return (void*)(VALUE)ptr->ret; // 解決したaddrinfoを返す
}
```

```c
// rb_thread_call_without_gvl()が割り込まれた際に呼ばれるubf()
static void
cancel_getaddrinfo(void *arg)
{
  struct getaddrinfo_arg *ptr = arg;
  rb_native_mutex_lock(&ptr->mutex);
  ptr->done = 2;
  rb_native_cond_signal(&ptr->cond); // 待機しているcondにcond_signalを送出
  rb_native_mutex_unlock(&ptr->mutex);
}
```

```c
static VALUE
finish_getaddrinfo(VALUE arg)
{
  struct getaddrinfo_arg *ptr = (struct getaddrinfo_arg *)arg;

  rb_native_mutex_lock(&ptr->mutex);

  if (0 == --ptr->refcount) { // refcountをデクリメントした値が0: これ以上解決するアドレスファミリがない場合
    rb_native_mutex_unlock(&ptr->mutex);
    rb_native_cond_destroy(&ptr->cond);   // 条件変数を削除
    rb_native_mutex_destroy(&ptr->mutex); // mutexを削除
  } else { // 未解決のアドレスファミリが残っている場合
    rb_native_mutex_unlock(&ptr->mutex);
  }

  return Qnil;
}
```

```c
// eval.c
VALUE
rb_ensure(
  VALUE (*b_proc)(VALUE), // wait_getaddrinfo()
  VALUE data1,            // (VALUE)&arg
  VALUE (*e_proc)(VALUE), // finish_getaddrinfo
  VALUE data2             // (VALUE)&arg
) {
  int state;
  volatile VALUE result = Qnil;
  VALUE errinfo;

  rb_execution_context_t * volatile ec = GET_EC();
  // (vm_core.h)
  //   #define GET_EC()     rb_current_execution_context(true)
  //
  //   static inline rb_execution_context_t *
  //   rb_current_execution_context(bool expect_ec)
  //   {
  //   #ifdef RB_THREAD_LOCAL_SPECIFIER
  //     #ifdef __APPLE__
  //     rb_execution_context_t *ec = rb_current_ec();
  //     #else
  //     rb_execution_context_t *ec = ruby_current_ec;
  //     #endif
  //   #else
  //     rb_execution_context_t *ec = native_tls_get(ruby_current_ec_key);
  //   #endif
  //     VM_ASSERT(!expect_ec || ec != NULL);
  //     return ec;
  //   }

  rb_ensure_list_t ensure_list;
  ensure_list.entry.marker = 0;
  ensure_list.entry.e_proc = e_proc; // finish_getaddrinfo()
  ensure_list.entry.data2 = data2;   // (VALUE)&arg
  ensure_list.next = ec->ensure_list;

  ec->ensure_list = &ensure_list;
  EC_PUSH_TAG(ec);

  if ((state = EC_EXEC_TAG()) == TAG_NONE) {
    result = (*b_proc) (data1); // wait_getaddrinfo((VALUE)&arg)を実行
  }

  EC_POP_TAG();
  errinfo = ec->errinfo;

  if (!NIL_P(errinfo) && !RB_TYPE_P(errinfo, T_OBJECT)) {
    ec->errinfo = Qnil;
  }

  ec->ensure_list=ensure_list.next;
  (*ensure_list.entry.e_proc)(ensure_list.entry.data2);
  ec->errinfo = errinfo;

  if (state) {
    EC_JUMP_TAG(ec, state);
  }

  return result;
}
```

```c
// (builtin.h)
//   typedef struct rb_execution_context_struct rb_execution_context_t;

// vm_core.h
struct rb_execution_context_struct {
  /* execution information */
  VALUE *vm_stack;		/* must free, must mark */
  size_t vm_stack_size;       /* size in word (byte size / sizeof(VALUE)) */
  rb_control_frame_t *cfp;

  struct rb_vm_tag *tag;

  /* interrupt flags */
  rb_atomic_t interrupt_flag;
  rb_atomic_t interrupt_mask; /* size should match flag */
#if defined(USE_VM_CLOCK) && USE_VM_CLOCK
  uint32_t checked_clock;
#endif

  rb_fiber_t *fiber_ptr;
  struct rb_thread_struct *thread_ptr;

  /* storage (ec (fiber) local) */
  struct rb_id_table *local_storage;
  VALUE local_storage_recursive_hash;
  VALUE local_storage_recursive_hash_for_trace;

  /* Inheritable fiber storage. */
  VALUE storage;

  /* eval env */
  const VALUE *root_lep;
  VALUE root_svar;

  /* ensure & callcc */
  rb_ensure_list_t *ensure_list;

  /* trace information */
  struct rb_trace_arg_struct *trace_arg;

  /* temporary places */
  VALUE errinfo;
  VALUE passed_block_handler; /* for rb_iterate */

  uint8_t raised_flag; /* only 3 bits needed */

  /* n.b. only 7 bits needed, really: */
  BITFIELD(enum method_missing_reason, method_missing_reason, 8);

  VALUE private_const_reference;

  /* for GC */
  struct {
    VALUE *stack_start;
    VALUE *stack_end;
    size_t stack_maxsize;
    RUBY_ALIGNAS(SIZEOF_VALUE) jmp_buf regs;
  } machine;
};

typedef struct rb_ensure_list {
  struct rb_ensure_list *next;
  struct rb_ensure_entry entry;
} rb_ensure_list_t;

typedef struct rb_ensure_entry {
  VALUE marker;
  VALUE (*e_proc)(VALUE);
  VALUE data2;
} rb_ensure_entry_t;
```
