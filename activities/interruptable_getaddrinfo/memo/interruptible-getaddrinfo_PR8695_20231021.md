- https://github.com/ruby/ruby/pull/8695/files

```ruby
# ext/socket/extconf.rb

  # ...
  [
    # ...
    pthread.h # <- 追加
    sched.h   # <- 追加
  ].each {|h|
    if have_header(h, headers)
      headers << h
    end
  }

  # ...
  have_func("pthread_create")         # <- 追加
  have_func("pthread_detach")         # <- 追加
  have_func("pthread_setaffinity_np") # <- 追加: スレッドにCPU affinityの設定・取得を行う
  have_func("sched_getcpu")           # <- 追加: 呼び出したスレッドが実行されているCPUの番号を返す
  # CPUアフィニティ ... プロセス・スレッドを実行するCPUコア
```

```c
// ext/socket/raddrinfo.c

#include "rubysocket.h"

// GETADDRINFO_IMPL == 0 : call getaddrinfo/getnameinfo directly
// GETADDRINFO_IMPL == 1 : call getaddrinfo/getnameinfo without gvl (but uncancellable)
// GETADDRINFO_IMPL == 2 : call getaddrinfo/getnameinfo in a dedicated pthread
//                         (and if the call is interrupted, the pthread is detached)

#ifndef GETADDRINFO_IMPL
#  ifdef GETADDRINFO_EMU
#    define GETADDRINFO_IMPL 0
#  elif !defined(HAVE_PTHREAD_CREATE) || !defined(HAVE_PTHREAD_DETACH) || defined(__MINGW32__) || defined(__MINGW64__)
#    define GETADDRINFO_IMPL 1
#  else
#    define GETADDRINFO_IMPL 2
#    include "ruby/thread_native.h"
#  endif
#endif

// ...

// rb_getaddrinfo() の追加 ----------------------------
// GETADDRINFO_IMPL == 0 : call getaddrinfo/getnameinfo directly
// GETADDRINFO_EMUが定義されている場合。内容は従来と変更なし
#if GETADDRINFO_IMPL == 0

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
  return getaddrinfo(hostp, portp, hints, ai);
}

// GETADDRINFO_IMPL == 1 : call getaddrinfo/getnameinfo without gvl (but uncancellable)
// pthreadが利用可能でない場合。内容は従来とほぼ変更なし
#elif GETADDRINFO_IMPL == 1

// 従来の getaddrinfo_arg() と変更なし
struct getaddrinfo_arg
{
  const char *node;
  const char *service;
  const struct addrinfo *hints;
  struct addrinfo **res;
};

// rb_thread_call_without_gvl() の中で nogvl_getaddrinfo() を呼び出すだけ。
static int
rb_getaddrinfo(
  const char *hostp,
  const char *portp,
  const struct addrinfo *hints,
  struct addrinfo **ai
) {
  struct getaddrinfo_arg arg;
  MEMZERO(&arg, struct getaddrinfo_arg, 1);
  arg.node = hostp;
  arg.service = portp;
  arg.hints = hints;
  arg.res = ai;
  return (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);
}

// 従来の getaddrinfo_arg() とほぼ変更なし。リファクタリング済み
static void *
nogvl_getaddrinfo(void *arg)
{
  int ret;
  struct getaddrinfo_arg *ptr = arg;

  ret = getaddrinfo(ptr->node, ptr->service, ptr->hints, ptr->res);
#ifdef __linux__
  /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
   * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
   */
  if (ret == EAI_SYSTEM && errno == ENOENT)
    ret = EAI_NONAME;
#endif
  return (void *)(VALUE)ret; // getaddrinfoの返り値
}

// GETADDRINFO_IMPL == 2 : call getaddrinfo/getnameinfo in a dedicated pthread
//                         (and if the call is interrupted, the pthread is detached)
// pthreadが利用可能な場合
#elif GETADDRINFO_IMPL == 2

struct getaddrinfo_arg
{
  char *node, *service;               // const が外れている
  struct addrinfo hints;              // const が外れている
  struct addrinfo *ai;                // 追加
  int err, refcount, done, cancelled; // 追加
  rb_nativethread_lock_t lock;        // 追加
  rb_nativethread_cond_t cond;        // 追加
  // struct addrinfo **res; が削除されている
};

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
  int retry;
  struct getaddrinfo_arg *arg;
  int err;

start:
  retry = 0;

  // 値を埋めたgetaddrinfo_arg構造体argへのポインタを返す
  arg = allocate_getaddrinfo_arg(hostp, portp, hints);

  if (!arg) {
    return EAI_MEMORY; // Memory allocation failure
  }

  pthread_t th;

  // 新しいスレッドでdo_getaddrinfo()を実行
  if (pthread_create(&th, 0, do_getaddrinfo, arg) != 0) {
    // スレッドの生成に失敗した場合、allocate_getaddrinfo_arg()で初期化した条件変数・ロックを削除
    free_getaddrinfo_arg(arg);
    return EAI_AGAIN;
  }

  // 生成したスレッドはjoinしないのでデタッチしておく (スレッドの終了時にスレッドによって消費されていたメモリ資源を即座に解放する)
  pthread_detach(th);

// pthread_setaffinity_np(3) および sched_getcpu(3) が利用できる環境の場合
#if defined(HAVE_PTHREAD_SETAFFINITY_NP) && defined(HAVE_SCHED_GETCPU)
  // CPU集合
  cpu_set_t tmp_cpu_set;
  // tmp_cpu_setを初期化
  CPU_ZERO(&tmp_cpu_set);
  // 呼び出したスレッドが現在実行されているCPUの番号をtmp_cpu_setにセット
  CPU_SET(sched_getcpu(), &tmp_cpu_set);
  // スレッド th のCPUアフィニティマスクにCPU集合 tmp_cpu_set を設定
  // thが現在 tmp_cpu_set 上で実行されていない場合は、tmp_cpu_set の指すCPUのいずれかに移動される
  pthread_setaffinity_np(th, sizeof(cpu_set_t), &tmp_cpu_set);
#endif

  // 1. 割り込みをチェックし、割り込みを検出したら cancel_getaddrinfo を呼び出し即座にリターン。シグナルには反応しない
  // 2. GVLを解放
  // 3. GVLなしで wait_getaddrinfo を呼び出し
  // 4. GVL を再取得するまでブロック
  rb_thread_call_without_gvl2(wait_getaddrinfo, arg, cancel_getaddrinfo, arg);

  int need_free = 0;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  {
    if (arg->done) {
      err = arg->err;
      if (err == 0) *ai = arg->ai;
    } else if (arg->cancelled) {
      err = EAI_AGAIN;
    } else {
      // なるほどー
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
  // 非同期の例外によって割り込まれた場合は後続で例外を発生させる
  // タイマスレッドによって割り込まれた場合、ここで後続の処理はそのままreturnする。なので手動でretryが必要
  // (前提) すべての処理はRubyスレッドとして動作している 
  // Rubyではプリエンプションを実現するため、明示的に作成されたRubyスレッドとは別に
  // 実行中のスレッドの割り込みフラグにタイマイベントを設定するネイティブスレッド (タイマスレッド) が実装されている
  // (タイマスレッドはRubyスレッドが二つ以上ある場合に動作する) 
  rb_thread_check_ints();
  // rb_thread_check_ints ... 割り込みをチェックする
  // Rubyではデフォルトでシグナルがマスクされており、rb_thread_check_intsを呼び出すことで保留中のシグナルがあるかどうかをチェックできる
  // 保留中のシグナルがある場合は、この関数で処理される

  if (retry) goto start;

  // 正常終了時はrb_getaddrinfoの第四引数のstruct addrinfo **aiにアドレスが格納されている
  // 返り値はエラーコード
  return err;
}

// 値を埋めたgetaddrinfo_arg構造体argへのポインタを返す
static struct getaddrinfo_arg *
allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addrinfo *hints)
{
  // ホスト名 + ポート番号分のメモリサイズbufsizeを確認
  size_t hostp_offset = sizeof(struct getaddrinfo_arg);
  size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);
  size_t bufsize = portp_offset + (portp ? strlen(portp) + 1 : 0);

  // bufsize 分のメモリを確保
  char *buf = malloc(bufsize);

  if (!buf) {
      rb_gc();
      buf = malloc(bufsize);
      if (!buf) return NULL;
  }

  // arg = bufsize 分のgetaddrinfo_arg構造体
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)buf;

  // arg に各値を詰める
  if (hostp) {
    arg->node = buf + hostp_offset;
    strcpy(arg->node, hostp);
  } else {
    arg->node = NULL;
  }

  if (portp) {
    arg->service = buf + portp_offset;
    strcpy(arg->service, portp);
  } else {
    arg->service = NULL;
  }

  arg->hints = *hints;
  arg->ai = NULL;

  arg->refcount = 2;
  arg->done = arg->cancelled = 0;

  rb_nativethread_lock_initialize(&arg->lock); // ロック (arg->lock) を初期化
  rb_native_cond_initialize(&arg->cond); // 条件変数 (arg->cond) を初期化

  return arg;
}

// allocate_getaddrinfo_arg()で初期化した条件変数・ロックを削除
static void
free_getaddrinfo_arg(struct getaddrinfo_arg *arg)
{
  rb_native_cond_destroy(&arg->cond);
  rb_nativethread_lock_destroy(&arg->lock);
  free(arg);
}

// 生成したスレッドで実行
static void *
do_getaddrinfo(void *ptr)
{
  // 引数ptrは値を埋めたgetaddrinfo_arg構造体argへのポインタ
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

  // getaddrinfo の実行
  int err;
  err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);

#ifdef __linux__
  /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
   * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
   */
  if (err == EAI_SYSTEM && errno == ENOENT)
    err = EAI_NONAME;
#endif

  // getaddrinfo の実行が完了
  // arg->aiにアドレスを取得

  int need_free = 0;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  {
    arg->err = err;
    if (arg->cancelled) { // 実はすでにキャンセル済みの場合は取得したアドレス領域を解放
      freeaddrinfo(arg->ai)
    } else {
      arg->done = 1;
      rb_native_cond_signal(&arg->cond); // wait_getaddrinfoに通知
    }
    if (--arg->refcount == 0) need_free = 1;
  }

  rb_nativethread_lock_unlock(&arg->lock);

  if (need_free) free_getaddrinfo_arg(arg);

  return 0;
}

// メインスレッドからGVLなしで呼び出す
static void *
wait_getaddrinfo(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  while (!arg->done && !arg->cancelled) {
    // do_getaddrinfo または cancel_getaddrinfo からの通知を待つ
    rb_native_cond_wait(&arg->cond, &arg->lock);
  }

  rb_nativethread_lock_unlock(&arg->lock);

  return 0;
}

// メインスレッドで rb_getaddrinfo に割り込みが発生したら呼ばれる
static void
cancel_getaddrinfo(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);
  {
    arg->cancelled = 1; // 生成したスレッドで実行している do_getaddrinfo に通知
    rb_native_cond_signal(&arg->cond); // wait_getaddrinfo に通知
  }
  rb_nativethread_lock_unlock(&arg->lock);
}

#endif
// rb_getaddrinfo() の追加ここまで ----------------------

// rb_getnameinfo() の変更 -----------------------------
// rb_getnameinfo() はいろんなメソッドの実装から依存されている
// GETADDRINFO_IMPL == 0 : call getaddrinfo/getnameinfo directly
#if GETADDRINFO_IMPL == 0

// インターフェースを他のパターンに合わせてGETADDRINFO_EMUの場合でもrb_getnameinfoを呼び出せるようにしただけ?
int
rb_getnameinfo(
  const struct sockaddr *sa,
  socklen_t salen,
  char *host,     // <- 追加
  size_t hostlen, // <- 追加
  char *serv,     // <- 追加
  size_t servlen, // <- 追加
  int flags       // <- 追加
) {
  return getnameinfo(sa, salen, host, hostlen, serv, servlen, flags);
}

// GETADDRINFO_IMPL == 1 : call getaddrinfo/getnameinfo without gvl (but uncancellable)
#elif GETADDRINFO_IMPL == 1

struct getnameinfo_arg // 変更なし
{
  const struct sockaddr *sa;
  socklen_t salen;
  int flags;
  char *host;
  size_t hostlen;
  char *serv;
  size_t servlen;
};

// インターフェースを他のパターンに合わせただけ?
int
rb_getnameinfo(
  const struct sockaddr *sa,
  socklen_t salen,
  char *host,     // <- 追加
  size_t hostlen, // <- 追加
  char *serv,     // <- 追加
  size_t servlen, // <- 追加
  int flags       // <- 追加
) {
  struct getnameinfo_arg arg;
  int ret;
  arg.sa = sa;
  arg.salen = salen;
  arg.host = host;       // <- 追加した引数を使用する
  arg.hostlen = hostlen; // <- 追加した引数を使用する
  arg.serv = serv;       // <- 追加した引数を使用する
  arg.servlen = servlen; // <- 追加した引数を使用する
  arg.flags = flags;     // <- 追加した引数を使用する

  ret = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getnameinfo, &arg, RUBY_UBF_IO, 0);
  return ret;
}

static void *
nogvl_getnameinfo(void *arg) // 変更なし
{
  struct getnameinfo_arg *ptr = arg;

  return (void *)(VALUE)getnameinfo(
    ptr->sa,
    ptr->salen,
    ptr->host,
    (socklen_t)ptr->hostlen,
    ptr->serv,
    (socklen_t)ptr->servlen,
    ptr->flags
  );
}

// GETADDRINFO_IMPL == 2 : call getaddrinfo/getnameinfo in a dedicated pthread
//                         (and if the call is interrupted, the pthread is detached)
#elif GETADDRINFO_IMPL == 2

struct getnameinfo_arg
{
  struct sockaddr *sa;
  socklen_t salen;
  int flags;
  char *host;
  size_t hostlen;
  char *serv;
  size_t servlen;
  int err, refcount, done, cancelled; // <- このパターンでのみ定義
  rb_nativethread_lock_t lock         // <- このパターンでのみ定義;
  rb_nativethread_cond_t cond         // <- このパターンでのみ定義;
};

int
rb_getnameinfo(
  const struct sockaddr *sa,
  socklen_t salen,
  char *host,
  size_t hostlen,
  char *serv,
  size_t servlen,
  int flags
) {
  int retry;

  // 値を埋めたgetnameinfo_arg構造体argへのポインタを返す 
  struct getnameinfo_arg *arg = allocate_getnameinfo_arg(sa, salen, hostlen, servlen, flags);
  int err;

start:
  retry = 0;

  // 値を埋めたgetnameinfo_arg構造体argへのポインタを返す。retryになった時に初期化し直す用?
  arg = allocate_getnameinfo_arg(sa, salen, hostlen, servlen, flags);

  if (!arg) {
    return EAI_MEMORY;
  }

  pthread_t th;

  // 新しいスレッドでdo_getnameinfo()を実行
  if (pthread_create(&th, 0, do_getnameinfo, arg) != 0) {
    // スレッドの生成に失敗した場合、allocate_getnameinfo_arg()で初期化した条件変数・ロックを削除
    free_getnameinfo_arg(arg);
    return EAI_AGAIN;
  }

  // 生成したスレッドはjoinしないのでデタッチしておく (スレッドの終了時にスレッドによって消費されていたメモリ資源を即座に解放する)
  pthread_detach(th);

// pthread_setaffinity_np(3) および sched_getcpu(3) が利用できる環境の場合
#if defined(HAVE_PTHREAD_SETAFFINITY_NP) && defined(HAVE_SCHED_GETCPU)
  // CPU集合
  cpu_set_t tmp_cpu_set;
  // tmp_cpu_setを初期化
  CPU_ZERO(&tmp_cpu_set);
  // 呼び出したスレッドが現在実行されているCPUの番号をtmp_cpu_setにセット
  CPU_SET(sched_getcpu(), &tmp_cpu_set);
  // スレッド th のCPUアフィニティマスクにCPU集合 tmp_cpu_set を設定
  // thが現在 tmp_cpu_set 上で実行されていない場合は、tmp_cpu_set の指すCPUのいずれかに移動される
  pthread_setaffinity_np(th, sizeof(cpu_set_t), &tmp_cpu_set);
#endif

  // 1. 割り込みをチェックし、割り込みを検出したら cancel_getnameinfo を呼び出し即座にリターン。シグナルには反応しない
  // 2. GVLを解放
  // 3. GVLなしで wait_getnameinfo を呼び出し
  // 4. GVL を再取得するまでブロック
  rb_thread_call_without_gvl2(wait_getnameinfo, arg, cancel_getnameinfo, arg);

  int need_free = 0;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  if (arg->done) {
    err = arg->err;
    if (err == 0) {
      if (host) memcpy(host, arg->host, hostlen);
      if (serv) memcpy(serv, arg->serv, servlen);
    }
  } else if (arg->cancelled) {
    err = EAI_AGAIN;
  } else {
    // If already interrupted, rb_thread_call_without_gvl2 may return without calling wait_getnameinfo.
    // In this case, it could be !arg->done && !arg->cancelled.
    arg->cancelled = 1;
    retry = 1;
  }

  if (--arg->refcount == 0) need_free = 1;

  rb_nativethread_lock_unlock(&arg->lock);

  if (need_free) free_getnameinfo_arg(arg);

  // If the current thread is interrupted by asynchronous exception, the following raises the exception.
  // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
  rb_thread_check_ints();
  if (retry) goto start;

  return err;
}

// 値を埋めたgetnameinfo_arg構造体argへのポインタを返す
static struct getnameinfo_arg *
allocate_getnameinfo_arg(const struct sockaddr *sa, socklen_t salen, size_t hostlen, size_t servlen, int flags)
{
  size_t sa_offset = sizeof(struct getnameinfo_arg);
  size_t host_offset = sa_offset + salen;
  size_t serv_offset = host_offset + hostlen;
  size_t bufsize = serv_offset + servlen;

  char *buf = malloc(bufsize);
  if (!buf) {
    rb_gc();
    buf = malloc(bufsize);
    if (!buf) return NULL;
  }
  struct getnameinfo_arg *arg = (struct getnameinfo_arg *)buf;

  arg->sa = (struct sockaddr *)(buf + sa_offset);
  memcpy(arg->sa, sa, salen);
  arg->salen = salen;
  arg->host = buf + host_offset;
  arg->hostlen = hostlen;
  arg->serv = buf + serv_offset;
  arg->servlen = servlen;
  arg->flags = flags;

  arg->refcount = 2;
  arg->done = arg->cancelled = 0;

  rb_nativethread_lock_initialize(&arg->lock);
  rb_native_cond_initialize(&arg->cond);

  return arg;
}

// allocate_getnameinfo_arg()で初期化した条件変数・ロックを削除
static void
free_getnameinfo_arg(struct getnameinfo_arg *arg)
{
  rb_native_cond_destroy(&arg->cond);
  rb_nativethread_lock_destroy(&arg->lock);

  free(arg);
}

// 生成したスレッドで実行
static void *
do_getnameinfo(void *ptr)
{
  struct getnameinfo_arg *arg = (struct getnameinfo_arg *)ptr;

  int err;
  // ext/socket/getnameinfo.c で実装されている
  err = getnameinfo(
    arg->sa,
    arg->salen,
    arg->host,
    (socklen_t)arg->hostlen,
    arg->serv,
    (socklen_t)arg->servlen,
    arg->flags
  );

  int need_free = 0;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  arg->err = err;

  if (!arg->cancelled) {
    arg->done = 1;
    rb_native_cond_signal(&arg->cond); // wait_getnameinfo に通知
  }

  if (--arg->refcount == 0) need_free = 1;

  rb_nativethread_lock_unlock(&arg->lock);

  if (need_free) free_getnameinfo_arg(arg);

  return 0;
}

// メインスレッドからGVLなしで呼び出す
static void *
wait_getnameinfo(void *ptr)
{
  struct getnameinfo_arg *arg = (struct getnameinfo_arg *)ptr;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  while (!arg->done && !arg->cancelled) {
    // do_getnameinfo または cancel_getnameinfo からの通知を待つ
    rb_native_cond_wait(&arg->cond, &arg->lock);
  }

  rb_nativethread_lock_unlock(&arg->lock);

  return 0;
}

// メインスレッドで rb_getnameinfo に割り込みが発生したら呼ばれる
static void
cancel_getnameinfo(void *ptr)
{
  struct getnameinfo_arg *arg = (struct getnameinfo_arg *)ptr;

  // 現在のスレッドがロックを取得するまでブロック
  rb_nativethread_lock_lock(&arg->lock);

  arg->cancelled = 1;
  rb_native_cond_signal(&arg->cond); // wait_getnameinfo に通知

  rb_nativethread_lock_unlock(&arg->lock);
}

#endif
// rb_getnameinfo() の変更ここまで -----------------------

// ...

// rsock_getaddrinfo() の変更 ---------------------------
// rb_getaddrinfo() の呼び出し以外は変更なし
struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
  struct rb_addrinfo* res = NULL;
  struct addrinfo *ai;
  char *hostp, *portp;
  int error = 0;
  char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
  int additional_flags = 0;

  // ホスト名、ポート番号をVALUE -> 文字列へ変換し、その値をchar*に格納
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
      error = rb_getaddrinfo(hostp, portp, hints, &ai); // <- 追加

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
