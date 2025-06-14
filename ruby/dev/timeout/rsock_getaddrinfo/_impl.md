# `ext/socket/raddrinfo.c`

```c
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
            if (!arg->done) arg->cancelled = 1;
        } else {
            rb_native_cond_wait(&arg->cond, &arg->lock);
        }
    }
    rb_nativethread_lock_unlock(&arg->lock);
    return 0;
}
```

TODO
- `rb_getaddrinfo`側でタイムアウトによるキャンセルを検出する仕組みが必要
