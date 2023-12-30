# 2023/12/29 master
(ext/socket/raddrinfo.c)
- `addrinfo_s_getaddrinfo` - `Addrinfo.getaddrinfo`メソッドの引数の処理をして`addrinfo_list_new`を呼ぶ
  - `addrinfo_list_new` - `struct rb_addrinfo`の先頭アドレスからAddrinfoオブジェクトをつくり、配列にして返す
    - `call_getaddrinfo` - `struct addrinfo hints`に情報を格納して`rsock_getaddrinfo`を呼ぶ
      - `rsock_getaddrinfo` - `hints`を処理して`rb_getaddrinfo`を呼び出す
        - `rb_getaddrinfo` - `do_pthread_create`を実行し、`wait_getaddrinfo`で待ち合わせる
          - `do_pthread_create` - pthreadを作ってその中で`do_pthread_create`を呼ぶ
            - `do_getaddrinfo` - getaddrinfoを呼ぶ
              - `getaddrinfo`
          - `wait_getaddrinfo` - `do_getaddrinfo`が返ってくるのを条件変数で待つ
          - `cancel_getaddrinfo` - `wait_getaddrinfo`の待機を中断させる

```c
// ext/socket/raddrinfo.c

// 環境ごとに呼び出す関数が異なる。中断可能なgetaddrinfoのターゲットはGETADDRINFO_IMPL == 2
// GETADDRINFO_IMPL == 0 : call getaddrinfo/getnameinfo directly
// GETADDRINFO_IMPL == 1 : call getaddrinfo/getnameinfo without gvl (but uncancellable)
// GETADDRINFO_IMPL == 2 : call getaddrinfo/getnameinfo in a dedicated pthread
//                         (and if the call is interrupted, the pthread is detached)

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
  int retry;
  struct getaddrinfo_arg *arg;
  int err;

start:
  retry = 0;

  arg = allocate_getaddrinfo_arg(hostp, portp, hints);
  if (!arg) {
    return EAI_MEMORY;
  }

  pthread_attr_t attr;
  if (pthread_attr_init(&attr) != 0) {
    free_getaddrinfo_arg(arg);
    return EAI_AGAIN;
  }

#if defined(HAVE_PTHREAD_ATTR_SETAFFINITY_NP) && defined(HAVE_SCHED_GETCPU)

  cpu_set_t tmp_cpu_set;
  CPU_ZERO(&tmp_cpu_set);
  int cpu = sched_getcpu();
  if (cpu < CPU_SETSIZE) {
    CPU_SET(cpu, &tmp_cpu_set);
    pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &tmp_cpu_set);
  }

#endif

  pthread_t th;
  if (do_pthread_create(&th, &attr, do_getaddrinfo, arg) != 0) {
    free_getaddrinfo_arg(arg);
    return EAI_AGAIN;
  }

  pthread_detach(th);

  rb_thread_call_without_gvl2(wait_getaddrinfo, arg, cancel_getaddrinfo, arg);

  int need_free = 0;
  rb_nativethread_lock_lock(&arg->lock);
  {
    if (arg->done) { // getaddrinfoが終わった
      err = arg->err;
      if (err == 0) *ai = arg->ai;
    } else if (arg->cancelled) { // 割り込みが発生した
      err = EAI_AGAIN;
    } else { // すでに中断済み。retryを利用してdo_getaddrinfo -> freeaddrinfoを呼ぶ
      // If already interrupted, rb_thread_call_without_gvl2 may return without calling wait_getaddrinfo.
      // In this case, it could be !arg->done && !arg->cancelled.
      arg->cancelled = 1; // to make do_getaddrinfo call freeaddrinfo
      retry = 1;
    }
    if (--arg->refcount == 0) need_free = 1;
  }
  rb_nativethread_lock_unlock(&arg->lock);

  if (need_free) free_getaddrinfo_arg(arg);

  // If the current thread is interrupted by asynchronous exception, the following raises the exception.
  // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
  rb_thread_check_ints();
  if (retry) goto start;

  return err;
}

static int
do_pthread_create(
  pthread_t *th,
  const pthread_attr_t *attr,
  void *(*start_routine) (void *),
  void *arg
) {
  int limit = 3, ret;
  do {
    // It is said that pthread_create may fail spuriously, so we follow the JDK and retry several times.
    //
    // https://bugs.openjdk.org/browse/JDK-8268605
    // https://github.com/openjdk/jdk/commit/e35005d5ce383ddd108096a3079b17cb0bcf76f1
    ret = pthread_create(th, attr, start_routine, arg);
  } while (ret == EAGAIN && limit-- > 0);
  return ret;
}

static void *
do_getaddrinfo(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

  int err;
  err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
#ifdef __linux__
  /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
   * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
   */
  if (err == EAI_SYSTEM && errno == ENOENT)
    err = EAI_NONAME;
#endif

  int need_free = 0;
  rb_nativethread_lock_lock(&arg->lock);
  {
    arg->err = err;
    // メインスレッドでの割り込み発生有無はgetaddrinfoが完了した後に検知する
    if (arg->cancelled) { // 割り込みが発生
      freeaddrinfo(arg->ai);
    } else { // getaddrinfoが完了
      arg->done = 1;
      rb_native_cond_signal(&arg->cond); // メインスレッドの条件変数にsignal
    }
    if (--arg->refcount == 0) need_free = 1;
  }
  rb_nativethread_lock_unlock(&arg->lock);

  if (need_free) free_getaddrinfo_arg(arg);

  return 0;
}

static void *
wait_getaddrinfo(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
  rb_nativethread_lock_lock(&arg->lock);

  // 割り込みが発生するか、getaddrinfoスレッドでgetaddrinfoが完了したらここに通知が来る
  while (!arg->done && !arg->cancelled) {
    rb_native_cond_wait(&arg->cond, &arg->lock);
  }

  rb_nativethread_lock_unlock(&arg->lock);
  return 0;
}

static void
cancel_getaddrinfo(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

  rb_nativethread_lock_lock(&arg->lock);
  {
    // ここはメインスレッド。
    // 割り込みが発生すると、arg->cancelledにフラグを立てる
    // このフラグはgetaddrinfoスレッドとメインスレッドで参照される
    // また、メインスレッドの条件変数へsignalを送る
    arg->cancelled = 1;
    rb_native_cond_signal(&arg->cond);
  }

  rb_nativethread_lock_unlock(&arg->lock);
}
```
