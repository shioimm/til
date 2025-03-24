# `rb_thread_prevent_fork`の導入
- https://github.com/ruby/ruby/commit/63cbe3f6ac9feb44a2e43b1f853e2ca7e049316c#diff-443562a7b162dc0d001a053a745f194c4dbbae5a68d94e9d385d86d9e670431bR335
- getaddrinfoはpthreadのmutexを使用する
- getaddrinfoが実行中に別スレッドでforkが発生すると、
  子プロセスはmutexのロック取られた状態がコピーされる
- 子プロセスではgetaddrinfoを実行しているスレッドは存在せず、
  ロックを解除する方法がないためデッドロックが発生する可能性がある

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
rb_thread_acquire_fork_lock(void)
{
    int r;
    if ((r = pthread_rwlock_wrlock(&rb_thread_fork_rw_lock))) {
        rb_bug_errno("pthread_rwlock_wrlock", r);
    }
}

void
rb_thread_release_fork_lock(void)
{
    int r;
    if ((r = pthread_rwlock_unlock(&rb_thread_fork_rw_lock))) {
        rb_bug_errno("pthread_rwlock_unlock", r);
    }
}

void
rb_thread_reset_fork_lock(void)
{
    int r;
    if ((r = pthread_rwlock_destroy(&rb_thread_fork_rw_lock))) {
        rb_bug_errno("pthread_rwlock_destroy", r);
    }

    if ((r = pthread_rwlock_init(&rb_thread_fork_rw_lock, NULL))) {
        rb_bug_errno("pthread_rwlock_init", r);
    }
}
```

```c
// process.c
// Process.fork -> rb_f_fork -> rb_call_proc__fork -> proc_fork_pid -> rb_fork_ruby

rb_pid_t
rb_fork_ruby(int *status)
{
    struct rb_process_status child = {.status = 0};
    rb_pid_t pid;
    int try_gc = 1;
    int err; // fork失敗時にGCを試みる

    struct child_handler_disabler_state old;

    do {
        prefork();

        before_fork_ruby();
        rb_thread_acquire_fork_lock(); // 追加
        // fork前に排他的書き込みロックを取得する
        // これによって他のスレッドによって同時にforkが実行されることを防ぐ

        disable_child_handler_before_fork(&old);

        child.pid = pid = rb_fork(); // fork(2) を実行

        // ここから先はfork後の世界 ---

        child.error = err = errno;
        disable_child_handler_fork_parent(&old);

        // ここから追加 ----
        rb_thread_release_fork_lock(); // ロックを解除し、他のスレッドがforkを呼び出せるようにする
        if (pid == 0) {
          rb_thread_reset_fork_lock(); // 子プロセス側でのロックの再初期化処理
        }
        // ここまで追加 ----

        after_fork_ruby(pid);

        /* repeat while fork failed but retryable */
    } while (pid < 0 && handle_fork_error(err, &child, NULL, &try_gc) == 0);
    // forkが失敗した場合にエラーを処理
    // handle_fork_errorが再試行可能と判断した場合ループを継続

    if (status) *status = child.status;

    return pid;
}

// マルチスレッドなプロセスでforkを呼び出すとき、子プロセスはforkを呼んだスレッド以外のスレッド状態を継承しない
// そのため、スレッド関連のデータが不整合な状態になり得る (ロックや待機中のスレッドなど)
// fork実行前後にロックの取得・解放を行うことにより、
// 複数スレッドが並行して動作している環境下でforkを安全に行えるようになる
```
