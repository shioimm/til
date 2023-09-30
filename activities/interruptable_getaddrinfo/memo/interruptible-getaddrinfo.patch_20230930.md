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

  hostp = host_str(host, hbuf, sizeof(hbuf), &additional_flags);
  portp = port_str(port, pbuf, sizeof(pbuf), &additional_flags);

  if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
    hints->ai_socktype = SOCK_DGRAM;
  }
  hints->ai_flags |= additional_flags;

  error = numeric_getaddrinfo(hostp, portp, hints, &ai);

  if (error == 0) {
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
#ifdef GETADDRINFO_EMU // (ext/socket/extconf.rb) enable_config("wide-getaddrinfo") ならここ
      error = getaddrinfo(hostp, portp, hints, &ai);
#else
      struct getaddrinfo_arg arg;

      MEMZERO(&arg, struct getaddrinfo_arg, 1);

      arg.node = hostp;
      arg.service = portp;
      arg.hints = hints;
      arg.res = &ai;

      // 以下変更
      //   変更前: error = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);
      arg.done = 0;
      arg.ret = 0;
      arg.refcount = 2;
      rb_native_mutex_initialize(&arg.mutex);
      rb_native_cond_initialize(&arg.cond);

      pthread_t t;
      // TODO: support win32
      if (pthread_create(&t, 0, do_getaddrinfo, &arg) != 0) {
        error = EAGAIN;
      }
      else {
        pthread_detach(t);
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

  // 以下変更
  //   変更前: return (void *)(VALUE)ret;
  rb_native_mutex_lock(&ptr->mutex);
  ptr->done = 1;
  pthread_cond_signal(&ptr->cond);
  if (0 == --ptr->refcount) {
      rb_native_mutex_unlock(&ptr->mutex);
      rb_native_cond_destroy(&ptr->cond);
      rb_native_mutex_destroy(&ptr->mutex);
  }
  else {
      rb_native_mutex_unlock(&ptr->mutex);
  }
  return 0;
}
```

```c
static void *
wait_getaddrinfo0(void *arg)
{
  struct getaddrinfo_arg *ptr = arg;
  rb_native_mutex_lock(&ptr->mutex);
  while (!ptr->done) {
      rb_native_cond_wait(&ptr->cond, &ptr->mutex);
  }
  rb_native_mutex_unlock(&ptr->mutex);
  return (void*)(VALUE)ptr->ret;
}

static void
cancel_getaddrinfo(void *arg)
{
  struct getaddrinfo_arg *ptr = arg;
  rb_native_mutex_lock(&ptr->mutex);
  ptr->done = 2;
  rb_native_cond_signal(&ptr->cond);
  rb_native_mutex_unlock(&ptr->mutex);
}

static VALUE
wait_getaddrinfo(VALUE arg)
{
  void *ptr = (void *)arg;
  return (VALUE)rb_thread_call_without_gvl(wait_getaddrinfo0, ptr, cancel_getaddrinfo, ptr);
}

static VALUE
finish_getaddrinfo(VALUE arg)
{
  struct getaddrinfo_arg *ptr = (struct getaddrinfo_arg *)arg;
  rb_native_mutex_lock(&ptr->mutex);
  if (0 == --ptr->refcount) {
    rb_native_mutex_unlock(&ptr->mutex);
    rb_native_cond_destroy(&ptr->cond);
    rb_native_mutex_destroy(&ptr->mutex);
  }
  else {
    rb_native_mutex_unlock(&ptr->mutex);
  }
  return Qnil;
}
```
