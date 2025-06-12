# 2025/6/8時点

```c
// TODO timeoutを受け取れるように引数を増やす
struct rb_addrinfo*
rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags)
{
    struct addrinfo hints;

    MEMZERO(&hints, struct addrinfo, 1);
    hints.ai_family = family;
    hints.ai_socktype = socktype;
    hints.ai_flags = flags;
    return rsock_getaddrinfo(host, port, &hints, 1);
}
```

```c
// TODO timeoutを受け取れるように引数を増やす
struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
    // ------- 準備 -------
    struct rb_addrinfo* res = NULL;
    struct addrinfo *ai;
    char *hostp, *portp;
    int error = 0;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;

    hostp = raddrinfo_host_str(host, hbuf, sizeof(hbuf), &additional_flags);
    portp = raddrinfo_port_str(port, pbuf, sizeof(pbuf), &additional_flags);

    if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
        hints->ai_socktype = SOCK_DGRAM;
    }
    hints->ai_flags |= additional_flags;
    // ------- 準備 -------

    // ------- numeric_getaddrinfo -------
    error = numeric_getaddrinfo(hostp, portp, hints, &ai);

    // 渡された文字列hostpをパースしてIPアドレスかどうかを判断し、
    // IPアドレスの場合はstruct addrinfoにして返しているだけなのでタイムアウト不要かも

    if (error == 0) {
        res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        res->allocated_by_malloc = 1;
        res->ai = ai;
    }
    // ------- numeric_getaddrinfo -------

    if (error != 0) {
        // ------- rb_scheduler_getaddrinfo -------
        VALUE scheduler = rb_fiber_scheduler_current();
        int resolved = 0;

        // Fiber::Scheduler用。スケジューラの実装に依存しそう
        // 値だけ渡して実際の制御をスケジューラに任せるような方針はありかもしれないけどあとで考える
        if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
            error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

            if (error != EAI_FAIL) {
                resolved = 1;
            }
        }
        // ------- rb_scheduler_getaddrinfo -------

        // ------- rb_getaddrinfo -------
        if (!resolved) {
            // TODO timeoutを渡す
            error = rb_getaddrinfo(hostp, portp, hints, &ai);
            if (error == 0) {
                res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                res->allocated_by_malloc = 0;
                res->ai = ai;
            }
        }
        // ------- rb_getaddrinfo -------
    }

    // ------- エラー処理 -------
    if (error) {
        if (hostp && hostp[strlen(hostp)-1] == '\n') {
            rb_raise(rb_eSocket, "newline at the end of hostname");
        }
        rsock_raise_resolution_error("getaddrinfo", error);
    }
    // ------- エラー処理 -------

    return res;
}
```

### `numeric_getaddrinfo`

```c
static int
numeric_getaddrinfo(
    const char *node, const char *service,
    const struct addrinfo *hints,
    struct addrinfo **res
) {
    // ...
    int port;

    // nodeがある、かつポート番号がvalidな場合
    static const struct {
        int socktype;
        int protocol;
    } list[] = {
        { SOCK_STREAM, IPPROTO_TCP },
        { SOCK_DGRAM, IPPROTO_UDP },
        { SOCK_RAW, 0 }
    };

    struct addrinfo *ai = NULL;
    int hint_family = hints ? hints->ai_family : PF_UNSPEC;
    int hint_socktype = hints ? hints->ai_socktype : 0;
    int hint_protocol = hints ? hints->ai_protocol : 0;
    char ipv4addr[4];
    char ipv6addr[16];

    // ...
    // nodeがIPv6アドレスを表す文字列である場合
    int i;
    for (i = numberof(list)-1; 0 <= i; i--) {
        if ((hint_socktype == 0 || hint_socktype == list[i].socktype) &&
            (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)) {
            struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
            struct sockaddr_in6 *sa = xmalloc(sizeof(struct sockaddr_in6));
            INIT_SOCKADDR_IN6(sa, sizeof(struct sockaddr_in6));
            memcpy(&sa->sin6_addr, ipv6addr, sizeof(ipv6addr));
            sa->sin6_port = htons(port);
            ai0->ai_family = PF_INET6;
            ai0->ai_socktype = list[i].socktype;
            ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
            ai0->ai_addrlen = sizeof(struct sockaddr_in6);
            ai0->ai_addr = (struct sockaddr *)sa;
            ai0->ai_canonname = NULL;
            ai0->ai_next = ai;
            ai = ai0;
        }
    }

    // ...
    // nodeがIPv4アドレスを表す文字列である場合
    int i;
    for (i = numberof(list)-1; 0 <= i; i--) {
        if ((hint_socktype == 0 || hint_socktype == list[i].socktype) &&
            (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)) {
            struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
            struct sockaddr_in *sa = xmalloc(sizeof(struct sockaddr_in));
            INIT_SOCKADDR_IN(sa, sizeof(struct sockaddr_in));
            memcpy(&sa->sin_addr, ipv4addr, sizeof(ipv4addr));
            sa->sin_port = htons(port);
            ai0->ai_family = PF_INET;
            ai0->ai_socktype = list[i].socktype;
            ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
            ai0->ai_addrlen = sizeof(struct sockaddr_in);
            ai0->ai_addr = (struct sockaddr *)sa;
            ai0->ai_canonname = NULL;
            ai0->ai_next = ai;
            ai = ai0;
        }
    }

    // ...
    if (ai) {
        *res = ai;
        return 0;
    }

    // そうでない場合は名前解決失敗
    return EAI_FAIL;
}
```

### `rb_scheduler_getaddrinfo`

```c
static int
rb_scheduler_getaddrinfo(
    VALUE scheduler, // rb_fiber_scheduler_current();
    VALUE host, const char *service,
    const struct addrinfo *hints,
    struct rb_addrinfo **res
) {
    int error, res_allocated = 0, _additional_flags = 0;
    long i, len;
    struct addrinfo *ai, *ai_tail = NULL;
    char *hostp;
    char _hbuf[NI_MAXHOST];
    VALUE ip_addresses_array, ip_address;

    // 実際の実装はスケジューラ用のクラスに依存する
    ip_addresses_array = rb_fiber_scheduler_address_resolve(scheduler, host);

    // Returns EAI_FAIL if the scheduler hook is not implemented:
    if (ip_addresses_array == Qundef) return EAI_FAIL;

    if (ip_addresses_array == Qnil) {
        len = 0;
    } else {
        len = RARRAY_LEN(ip_addresses_array);
    }

    // ip_addresses_array (IPアドレスを表すRubyオブジェクトのC配列)
    for(i=0; i<len; i++) {
        ip_address = rb_ary_entry(ip_addresses_array, i);
        hostp = raddrinfo_host_str(ip_address, _hbuf, sizeof(_hbuf), &_additional_flags);
        error = numeric_getaddrinfo(hostp, service, hints, &ai);

        // IPアドレスをstruct addrinfoに詰め直している
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

### `rb_getaddrinfo`

```c
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
```

#### `GETADDRINFO_IMPL` 0 の場合
- getaddrinfo(2) を直接呼んでいるのでタイムアウトできない

```c
static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    return getaddrinfo(hostp, portp, hints, ai);
}
```

#### `GETADDRINFO_IMPL` 1 の場合 (Win)
- `rb_thread_call_without_gvl`をタイムアウトさせる方法がないので今の実装だとタイムアウトできない
- 中断可能なgetaddrinfoのWin対応が進めば...?

```c
struct getaddrinfo_arg
{
    const char *node;
    const char *service;
    const struct addrinfo *hints;
    struct addrinfo **res;
};

static void *
nogvl_getaddrinfo(void *arg)
{
    int ret;
    struct getaddrinfo_arg *ptr = arg;
    ret = getaddrinfo(ptr->node, ptr->service, ptr->hints, ptr->res);

    #ifdef __linux__ // これはdo_getaddrinfoの中にある定義のコピー?
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (ret == EAI_SYSTEM && errno == ENOENT) {
        ret = EAI_NONAME;
    }
    #endif

    return (void *)(VALUE)ret;
}

static void *
fork_safe_getaddrinfo(void *arg)
{
    // thread_pthread.c
    // void *
    // rb_thread_prevent_fork(void *(*func)(void *), void *data)
    // {
    //     int r;
    //     if ((r = pthread_rwlock_rdlock(&rb_thread_fork_rw_lock))) {
    //         rb_bug_errno("pthread_rwlock_rdlock", r);
    //     }
    //     void *result = func(data);
    //     rb_thread_release_fork_lock();
    //     return result;
    // }

    return rb_thread_prevent_fork(nogvl_getaddrinfo, arg);
}

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    struct getaddrinfo_arg arg;
    MEMZERO(&arg, struct getaddrinfo_arg, 1);
    arg.node = hostp;
    arg.service = portp;
    arg.hints = hints;
    arg.res = ai;
    return (int)(VALUE)rb_thread_call_without_gvl(fork_safe_getaddrinfo, &arg, RUBY_UBF_IO, 0);
}
```

#### `GETADDRINFO_IMPL` 2 の場合

```c
struct getaddrinfo_arg
{
    char *node, *service;
    struct addrinfo hints;
    struct addrinfo *ai;
    int err, gai_errno, refcount, done, cancelled;
    rb_nativethread_lock_t lock;
    rb_nativethread_cond_t cond;
};

// TODO timeoutを受け取れるように引数を増やす
static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    int retry;
    struct getaddrinfo_arg *arg;
    int err = 0, gai_errno = 0;

start:
    retry = 0;

    // struct getaddrinfo_arg にいろいろ詰める
    // TODO timeoutをセットする
    arg = allocate_getaddrinfo_arg(hostp, portp, hints);
    if (!arg) return EAI_MEMORY;

    pthread_t th;

    // pthread を作成して fork_safe_do_getaddrinfo を呼ぶ
    // fork_safe_do_getaddrinfo は rb_thread_prevent_fork の中で do_getaddrinfo を呼ぶ
    if (raddrinfo_pthread_create(&th, fork_safe_do_getaddrinfo, arg) != 0) {
        int err = errno;
        // 条件変数とロックの削除、argのメモリ解放
        free_getaddrinfo_arg(arg);
        errno = err;
        return EAI_SYSTEM;
    }

    pthread_detach(th);

    // TODO wait_getaddrinfo をタイムアウトさせる方法を考える
    // - rb_native_cond_timedwait を使う場合、タイムアウトすると wait_getaddrinfo から返ってくる
    // - arg->cancelled = 1をセットする必要あり (子スレッドで資源を解放するため)
    // - もちろん retry = 1 は不要
    // - rb_thread_check_intsで例外は発生する? そうでない場合は何らかの方法で発生させないといけない
    rb_thread_call_without_gvl2(
        // GVLを解放して wait_getaddrinfo を呼ぶ
        // arg->done か arg->cancelled いずれかにフラグがセットされるまで条件変数で待機
        wait_getaddrinfo,
        arg,

        // 待機中に中断を検知した際に呼ぶ (シグナル、Thread#raise、タイマースレッド)
        // arg->cancelled にフラグをセット、arg->cond に通知
        cancel_getaddrinfo,
        arg
    );

    // ここに来た時点で待機が終わっている
    // arg->done か arg->cancelled にフラグが立っている状況

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        if (arg->done) { // 正常に名前解決でた
            err = arg->err;
            gai_errno = arg->gai_errno;
            if (err == 0) *ai = arg->ai;
        } else if (arg->cancelled) { // cancel_getaddrinfoが呼ばれた (= 待機中に中断された)
            retry = 1;
        } else { // rb_thread_call_without_gvl2 を呼ぶ前に中断されていた
            // If already interrupted, rb_thread_call_without_gvl2 may return without calling wait_getaddrinfo.
            // In this case, it could be !arg->done && !arg->cancelled.
            arg->cancelled = 1; // to make do_getaddrinfo call freeaddrinfo
            retry = 1;
        }

        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    // 子スレッドがすでに終了している場合はここで free_getaddrinfo_arg が呼ばれる
    if (need_free) free_getaddrinfo_arg(arg);

    // If the current thread is interrupted by asynchronous exception, the following raises the exception.
    // (現在のスレッドが非同期例外によって割り込まれた場合、 rb_thread_check_ints は例外を発生させる
    // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
    // (ただし現在のスレッドがタイマースレッドによって割り込まれた場合、 rb_thread_check_ints は例外を発生させずに
    //  戻る。手動で再試行する必要がある。

    // - 明示的にキャンセルされた場合 -> rb_thread_check_ints() で例外が発生
    // - タイマースレッドに割り込まれた場合 -> retry = 1 にセットして do_getaddrinfo を呼び直す
    // このときいずれも、前に do_getaddrinfo を呼んだ時のスレッドの中ではまだ getaddrinfo が続いており、
    // その getaddrinfo から返ってきた後で freeaddrinfo しないといけない。
    // そのために arg->cancelledにフラグをセットしておく。

    // 明示的に中断された場合はここで例外が発生
    rb_thread_check_ints();

    // タイマースレッドによる中断の場合はここでstartに戻る
    if (retry) goto start;

    /* Because errno is threadlocal, the errno value we got from the call to getaddrinfo() in the thread
     * (in case of EAI_SYSTEM return value) is not propagated to the caller of _this_ function. Set errno
     * explicitly, as round-tripped through struct getaddrinfo_arg, to deal with that */
    // (errnoはスレッドローカル。
    //  子スレッド内で getaddrinfo() を呼び出して取得したerrnoの値 (EAI_SYSTEM の場合) は、呼び出し元に伝播しない。
    //  struct getaddrinfo_arg を介して受け渡された値を使って、errno を明示的に設定する必要がある)
    if (gai_errno) errno = gai_errno;

    return err;
}

static struct getaddrinfo_arg *
allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addrinfo *hints)
{
    size_t hostp_offset = sizeof(struct getaddrinfo_arg);
    size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);
    size_t bufsize = portp_offset + (portp ? strlen(portp) + 1 : 0);
    char *buf = malloc(bufsize);

    if (!buf) {
        rb_gc();
        buf = malloc(bufsize);
        if (!buf) return NULL;
    }

    struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)buf;

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

    rb_nativethread_lock_initialize(&arg->lock);
    rb_native_cond_initialize(&arg->cond);

    return arg;
}

int
raddrinfo_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg)
{
    int limit = 3, ret;

    do {
        // It is said that pthread_create may fail spuriously, so we follow the JDK and retry several times.
        //
        // https://bugs.openjdk.org/browse/JDK-8268605
        // https://github.com/openjdk/jdk/commit/e35005d5ce383ddd108096a3079b17cb0bcf76f1
        ret = pthread_create(th, 0, start_routine, arg);
    } while (ret == EAGAIN && limit-- > 0);

    return ret;
}

static void *
fork_safe_do_getaddrinfo(void *ptr)
{
    // thread_pthread.c
    // void *
    // rb_thread_prevent_fork(void *(*func)(void *), void *data)
    // {
    //     int r;
    //     if ((r = pthread_rwlock_rdlock(&rb_thread_fork_rw_lock))) {
    //         rb_bug_errno("pthread_rwlock_rdlock", r);
    //     }
    //     void *result = func(data);
    //     rb_thread_release_fork_lock();
    //     return result;
    // }

    return rb_thread_prevent_fork(do_getaddrinfo, ptr);
}

static void *
do_getaddrinfo(void *ptr) // WIP
{
    struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

    int err, gai_errno;
    err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
    gai_errno = errno;

    #ifdef __linux__
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (err == EAI_SYSTEM && errno == ENOENT) {
        err = EAI_NONAME;
    }
    #endif

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        arg->err = err;
        arg->gai_errno = gai_errno;

        if (arg->cancelled) { // getaddrinfo から返ってきたものの、もうこの資源は使えない場合 (何らかの理由で中断)
            if (arg->ai) freeaddrinfo(arg->ai);
        } else {
            arg->done = 1; // 実行済みフラグにセット
            rb_native_cond_signal(&arg->cond); // 条件変数に通知
        }

        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    // メインスレッドがすでに終了している場合はここで free_getaddrinfo_arg が呼ばれる
    if (need_free) free_getaddrinfo_arg(arg);

    return 0;
}

static void
free_getaddrinfo_arg(struct getaddrinfo_arg *arg)
{
    rb_native_cond_destroy(&arg->cond);
    rb_nativethread_lock_destroy(&arg->lock);
    free(arg);
}

static void *
wait_getaddrinfo(void *ptr)
{
    struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

    rb_nativethread_lock_lock(&arg->lock);
    while (!arg->done && !arg->cancelled) {
        rb_native_cond_wait(&arg->cond, &arg->lock); // -> TODO rb_native_cond_timedwait を使いたい
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
        arg->cancelled = 1; // キャンセルフラグのセット
        rb_native_cond_signal(&arg->cond); // 条件変数に通知
    }
    rb_nativethread_lock_unlock(&arg->lock);
}
```

#### `rb_native_cond_timedwait`

- `thread_pthread.c`
- `thread_win32.c`
- `thread_none.c`

```c
// thread_pthread.c

void
rb_native_cond_timedwait(rb_nativethread_cond_t *cond, pthread_mutex_t *mutex, unsigned long msec)
{
    // タイムアウトする絶対時刻を返す
    rb_hrtime_t hrmsec = native_cond_timeout(cond, RB_HRTIME_PER_MSEC * msec);
    native_cond_timedwait(cond, mutex, &hrmsec);
}

static rb_hrtime_t
native_cond_timeout(
    rb_nativethread_cond_t *cond, // 条件変数 ... 使ってない?
    const rb_hrtime_t rel // 相対タイムアウト時間
) {
    // rb_hrtime_add = システムの単調クロックをnsec単位で加算する
    if (condattr_monotonic) { // 単調クロックが使えるプラットフォームの場合
        // 現在の単調クロック + rel
        return rb_hrtime_add(rb_hrtime_now(), rel);
    } else {
        struct timespec ts;
        rb_timespec_now(&ts);

        // 現在時刻 + rel
        return rb_hrtime_add(rb_timespec2hrtime(&ts), rel);
    }
}

static int
native_cond_timedwait(
    rb_nativethread_cond_t *cond,
    pthread_mutex_t *mutex,
    const rb_hrtime_t *abs // タイムアウトする絶対時刻
) {
    int r;
    struct timespec ts;

    /*
     * An old Linux may return EINTR. Even though POSIX says
     *   "These functions shall not return an error code of [EINTR]".
     *   http://pubs.opengroup.org/onlinepubs/009695399/functions/pthread_cond_timedwait.html
     * Let's hide it from arch generic code.
     */
    do {
        rb_hrtime2timespec(&ts, abs); // abs をstruct timespec にセット
        r = pthread_cond_timedwait(cond, mutex, &ts); // 条件が通知されるかタイムアウトするまで待機
    } while (r == EINTR); // EINTRで中断した場合は再試行

    if (r != 0 && r != ETIMEDOUT) rb_bug_errno("pthread_cond_timedwait", r); // エラー処理

    return r;
}
```

#### `getaddrinfo`の実装
- `macOS` / `AIX` > `INET6` && `LOOKUP_ORDER_HACK`

```c
// INET6 が定義されている
// かつ LOOKUP_ORDER_HACK_INET または LOOKUP_ORDER_HACK_INET6 が定義されている
#if defined(INET6) && (defined(LOOKUP_ORDER_HACK_INET) || defined(LOOKUP_ORDER_HACK_INET6))
  #define getaddrinfo(node,serv,hints,res) ruby_getaddrinfo((node),(serv),(hints),(res))
#endif

// AIX系OS
#if defined(_AIX)
  #undef getaddrinfo
  #define getaddrinfo(node,serv,hints,res) ruby_getaddrinfo__aix((node),(serv),(hints),(res))
#endif

// macOSの場合
#if defined(__APPLE__)
  #undef getaddrinfo
  #define getaddrinfo(node,serv,hints,res) ruby_getaddrinfo__darwin((node),(serv),(hints),(res))
#endif

// ------- ruby_getaddrinfo -------
static int
ruby_getaddrinfo(const char *nodename, const char *servname,
                 const struct addrinfo *hints, struct addrinfo **res)
{
    struct addrinfo tmp_hints;
    int i, af, error;

    if (hints->ai_family != PF_UNSPEC) {
        return getaddrinfo(nodename, servname, hints, res);
    }

    for (i = 0; i < LOOKUP_ORDERS; i++) {
        af = lookup_order_table[i];
        MEMCPY(&tmp_hints, hints, struct addrinfo, 1);
        tmp_hints.ai_family = af;
        error = getaddrinfo(nodename, servname, &tmp_hints, res);
        if (error) {
            if (tmp_hints.ai_family == PF_UNSPEC) {
                break;
            }
        }
        else {
            break;
        }
    }

    return error;
}

// ------- ruby_getaddrinfo__aix -------
static int
ruby_getaddrinfo__aix(const char *nodename, const char *servname,
                      const struct addrinfo *hints, struct addrinfo **res)
{
    int error = getaddrinfo(nodename, servname, hints, res);
    struct addrinfo *r;
    if (error)
        return error;
    for (r = *res; r != NULL; r = r->ai_next) {
        if (r->ai_addr->sa_family == 0)
            r->ai_addr->sa_family = r->ai_family;
        if (r->ai_addr->sa_len == 0)
            r->ai_addr->sa_len = r->ai_addrlen;
    }
    return 0;
}

// ------- ruby_getaddrinfo__darwin -------
static int
ruby_getaddrinfo__darwin(const char *nodename, const char *servname,
                         const struct addrinfo *hints, struct addrinfo **res)
{
    /* fix [ruby-core:29427] */
    const char *tmp_servname;
    struct addrinfo tmp_hints;
    int error;

    tmp_servname = servname;
    MEMCPY(&tmp_hints, hints, struct addrinfo, 1);
    if (nodename && servname) {
        if (str_is_number(tmp_servname) && atoi(servname) == 0) {
            tmp_servname = NULL;
            #ifdef AI_NUMERICSERV
            if (tmp_hints.ai_flags) tmp_hints.ai_flags &= ~AI_NUMERICSERV;
            #endif
        }
    }

    error = getaddrinfo(nodename, tmp_servname, &tmp_hints, res);
    if (error == 0) {
        /* [ruby-dev:23164] */
        struct addrinfo *r;
        r = *res;
        while (r) {
            if (! r->ai_socktype) r->ai_socktype = hints->ai_socktype;
            if (! r->ai_protocol) {
                if (r->ai_socktype == SOCK_DGRAM) {
                    r->ai_protocol = IPPROTO_UDP;
                }
                else if (r->ai_socktype == SOCK_STREAM) {
                    r->ai_protocol = IPPROTO_TCP;
                }
            }
            r = r->ai_next;
        }
    }

    return error;
}
```

```ruby
# ext/socket/extconf.rb

case with_config("lookup-order-hack", "UNSPEC")
when "INET"
  $defs << "-DLOOKUP_ORDER_HACK_INET"
when "INET6"
  $defs << "-DLOOKUP_ORDER_HACK_INET6"
when "UNSPEC"
  # nothing special
else
  # ...
end
```

## 呼び出し側
- `rsock_getaddrinfo` <変更対象>
  - `rsock_addrinfo` <変更対象>
    - (なし) `sock_s_gethostbyname` (`Socket.gethostbyname`) [ext/socket/socket.c]
    - (なし) `sock_s_pack_sockaddr_in` (`Socket.sockaddr_in` / `Socket.pack_sockaddr_in`) [ext/socket/socket.c]
    -  `init_inetsock_internal` / `init_fast_fallback_inetsock_internal` [ext/socket/ipsocket.c] <対応中>
      - `rsock_init_inetsock` [ext/socket/ipsocket.c]
        - (なし -> あり) `tcp_init` (`TCPSocket#initialize`) [ext/socket/tcpsocket.c]
        - (なし) `socks_init` (`SOCKSSocket#initialize`) [ext/socket/sockssocket.c]
        - (なし) `tcp_svr_init` (`TCPServer#initialize`) [ext/socket/tcpserver.c]
    - (なし) `ip_s_getaddress` (`IPSocket.getaddress`) [ext/socket/ipsocket.c]
    - (なし) `tcp_s_gethostbyname` (`TCPSocket.gethostbyname`) (ext/socket/tcpsocket.c) [ext/socket/tcpsocket.c]
    - (なし) `udp_connect` (`UDPSocket#connect`) [ext/socket/udpsocket.c]
    - (なし) `udp_bind` (`UDPSocket#bind`) [ext/socket/udpsocket.c]
    - (なし) `udp_send` (`UDPSocket#send`) [ext/socket/udpsocket.c]
  - `call_getaddrinfo`
    - `init_addrinfo_getaddrinfo`
      - (なし) `addrinfo_initialize` (`Addrinfo#initialize`) [ext/socket/raddrinfo.c]
    - `addrinfo_firstonly_new`
      - (なし) `addrinfo_s_ip` (`Addrinfo.ip`) [ext/socket/raddrinfo.c]
      - (なし) `addrinfo_s_tcp` (`Addrinfo.tcp`) [ext/socket/raddrinfo.c]
      - (なし) `addrinfo_s_udp` (`Addrinfo.udp`) [ext/socket/raddrinfo.c]
    - `addrinfo_list_new`
      - (あり) `addrinfo_s_getaddrinfo` (`Addrinfo.getaddrinfo`) [ext/socket/raddrinfo.c]
    - (なし) `addrinfo_mload` (`Addrinfo.marshal_load`) [ext/socket/raddrinfo.c]
