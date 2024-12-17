# `rb_thread_prevent_fork`の導入
https://github.com/ruby/ruby/commit/63cbe3f6ac9feb44a2e43b1f853e2ca7e049316c#diff-443562a7b162dc0d001a053a745f194c4dbbae5a68d94e9d385d86d9e670431bR335

```c
// ext/socket/raddrinfo.c

static void *
fork_safe_getaddrinfo(void *arg)
{
    return rb_thread_prevent_fork(nogvl_getaddrinfo, arg);
}

static void *
fork_safe_do_getaddrinfo(void *ptr)
{
    return rb_thread_prevent_fork(do_getaddrinfo, ptr);
}
```

```c
// #include <pthread.h>
// int pthread_rwlock_rdlock(pthread_rwlock_t *lock);
//   読み書きロックlockに読み取りロックを適用する
//   書き込み機能がロックを保持していない、かつロックにブロックされている書き込み機能がない場合はロックに成功する
// int pthread_rwlock_unlock(pthread_rwlock_t *lock);
//   読み取りまたは書き込みロックlockを解放

// fork read-write lock (only for pthread)
static pthread_rwlock_t rb_thread_fork_rw_lock = PTHREAD_RWLOCK_INITIALIZER;

void *
rb_thread_prevent_fork(void *(*func)(void *), void *data)
{
    int r;
    if ((r = pthread_rwlock_rdlock(&rb_thread_fork_rw_lock))) {
        rb_bug_errno("pthread_rwlock_rdlock", r);
    }
    void *result = func(data);
    rb_thread_release_fork_lock();
    return result;
}

void
rb_thread_release_fork_lock(void)
{
    int r;
    if ((r = pthread_rwlock_unlock(&rb_thread_fork_rw_lock))) {
        rb_bug_errno("pthread_rwlock_unlock", r);
    }
}
```

```c
// process.c

rb_pid_t
rb_fork_ruby(int *status)
{
    struct rb_process_status child = {.status = 0};
    rb_pid_t pid;
    int try_gc = 1, err;
    struct child_handler_disabler_state old;

    do {
        prefork();

        before_fork_ruby();
        rb_thread_acquire_fork_lock(); // 追加
        disable_child_handler_before_fork(&old);

        child.pid = pid = rb_fork();
        child.error = err = errno;

        disable_child_handler_fork_parent(&old); /* yes, bad name */

        // ここから追加 ----
        rb_thread_release_fork_lock();
        if (pid == 0) {
          rb_thread_reset_fork_lock();
        }
        // ここまで追加 ----

        after_fork_ruby(pid);

        /* repeat while fork failed but retryable */
    } while (pid < 0 && handle_fork_error(err, &child, NULL, &try_gc) == 0);

    if (status) *status = child.status;

    return pid;
}
```
