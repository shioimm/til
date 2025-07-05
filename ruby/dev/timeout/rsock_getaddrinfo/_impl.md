# `ext/socket/raddrinfo.c`

```c
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
