# 実装
## タイムアウトの実装

```c
// ext/socket/raddrinfo.c

struct getaddrinfo_arg
{
    char *node, *service;
    struct addrinfo hints;
    struct addrinfo *ai;
    int err, gai_errno, refcount, done, cancelled, timedout;
    rb_nativethread_lock_t lock;
    rb_nativethread_cond_t cond;
};

static struct getaddrinfo_arg *
allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addrinfo *hints)
{
    // ...
    arg->done = arg->cancelled = arg->timedout = 0;
    // ...
}

static void *
wait_getaddrinfo(void *ptr)
{
    struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
    rb_nativethread_lock_lock(&arg->lock);
    while (!arg->done && !arg->cancelled) {
        // WIP
        unsigned long msec = 1;
        if (msec) {
            rb_native_cond_timedwait(&arg->cond, &arg->lock, msec);
            if (!arg->done) {
                arg->cancelled = 1;
                arg->timedout = 1;
            }
        } else {
            rb_native_cond_wait(&arg->cond, &arg->lock);
        }
    }
    rb_nativethread_lock_unlock(&arg->lock);
    return 0;
}

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    int retry;
    struct getaddrinfo_arg *arg;
    int err = 0, gai_errno = 0;

    // ...

    rb_thread_call_without_gvl2(wait_getaddrinfo, arg, cancel_getaddrinfo, arg);

    // ...

    if (need_free) free_getaddrinfo_arg(arg);

    if (arg->timedout) rb_raise(etimedout_error, "user specified timeout");

    // If the current thread is interrupted by asynchronous exception, the following raises the exception.
    // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
    rb_thread_check_ints();
    if (retry) goto start;

    // ...
}
```

## 呼び出し側の実装
#### VALUE -> unsigned int

```c
// ext/socket/rubysocket.h

unsigned int rsock_value_timeout_to_msec(VALUE);
```

```c
// ext/socket/raddrinfo.c

unsigned int
rsock_value_timeout_to_msec(VALUE timeout)
{
    double seconds = NUM2DBL(timeout);
    if (seconds < 0) rb_raise(rb_eArgError, "timeout must not be negative");

    double msec = seconds * 1000.0;
    if (msec > UINT_MAX) rb_raise(rb_eArgError, "timeout too large");

    return (unsigned int)(msec + 0.5);
}
```

#### `call_getaddrinfo`

```c
// ext/socket/raddrinfo.c

static struct rb_addrinfo *
call_getaddrinfo(VALUE node, VALUE service,
                 VALUE family, VALUE socktype, VALUE protocol, VALUE flags,
                 int socktype_hack, VALUE timeout)
{
    // ...
    unsigned int t = rsock_value_timeout_to_msec(timeout);
    res = rsock_getaddrinfo(node, service, &hints, socktype_hack); // ここにtを渡す
    // ...
}
```
