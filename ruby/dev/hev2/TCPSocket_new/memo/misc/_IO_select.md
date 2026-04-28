# `IO.sselect`
- `rb_f_select` (io.c)
  - -> `select_call` (io.c)
  - -> `select_internal` (io.c)
  - -> `rb_thread_fd_select` (thread.c)
  - -> `do_select` (thread.c)
  - -> `native_fd_select` (`thread_pthread.c` / `thread_win32.c`)

#### pthreadがある環境
- `native_fd_select` (`thread_pthread.c`)
  - -> `rb_fd_select` (`thread_pthread.c`)
    - `include/ruby/internal/intern/select/posix.h`
      - -> `#define rb_fd_select select` 古いOSで使用される
    - `include/ruby/internal/intern/select/largesize.h`
      - -> `rb_fd_select` (thread.c)
      - -> `select`

```c
// include/ruby/internal/intern/select/largesize.h
/*
 * ...
 * Several Unix  platforms support file  descriptors bigger than  FD_SETSIZE in
 * `select(2)` system call.
 *
 * ...
 *
 * When `fd_set` is not  big enough to hold big file  descriptors, it should be
 * allocated dynamically.   Note that  this assumes  `fd_set` is  structured as
 * bitmap.
 *
 * `rb_fd_init` allocates the memory.
 * `rb_fd_term` frees the memory.
 * `rb_fd_set` may re-allocate bitmap.
 *
 * So `rb_fd_set` doesn't reject file descriptors bigger than `FD_SETSIZE`.
 * /
```

```c
// include/ruby/internal/intern/select/largesize.h
/**
 * The data  structure which wraps the  fd_set bitmap used by  select(2).  This
 * allows Ruby to use FD sets  larger than that allowed by historic limitations
 * on modern platforms.
 */
typedef struct {
    int maxfd;                  /**< Maximum allowed number of FDs. */ // 許可されるFDの最大数
    fd_set *fdset;              /**< File descriptors buffer */ // ファイルディスクリプタのバッファ
} rb_fdset_t;

// thread.c
int
rb_fd_select(int n, rb_fdset_t *readfds, rb_fdset_t *writefds, rb_fdset_t *exceptfds, struct timeval *timeout)
{
    fd_set *r = NULL, *w = NULL, *e = NULL;

    // n            = 監視対象の最大ファイルディスクリプタ番号
    // rb_fd_resize = FD_SETSIZE以上のfdに対応する分のメモリをxreallocで確保
    // rb_fd_ptr    = fd_setのポインタを取得

    if (readfds) {
        rb_fd_resize(n - 1, readfds);
        r = rb_fd_ptr(readfds);
    }
    if (writefds) {
        rb_fd_resize(n - 1, writefds);
        w = rb_fd_ptr(writefds);
    }
    if (exceptfds) {
        rb_fd_resize(n - 1, exceptfds);
        e = rb_fd_ptr(exceptfds);
    }

    // 監視対象となる最大ファイルディスクリプタ番号
    // およびリサイズされたビットマップへのポインタをselectに渡す
    return select(n, r, w, e, timeout);
}
```

#### Win環境
- `native_fd_select` (`thread_win32.c`)
  - `rb_w32_select_with_thread` (win32/win32.c)
