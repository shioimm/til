# `do_select`

```c
struct select_set {
  int max;
  rb_thread_t *th;
  rb_fdset_t *rset;
  rb_fdset_t *wset;
  rb_fdset_t *eset;
  rb_fdset_t orig_rset;
  rb_fdset_t orig_wset;
  rb_fdset_t orig_eset;
  struct timeval *timeout;
};

static VALUE
do_select(VALUE p)
{
  struct select_set *set = (struct select_set *)p;

  volatile int result = 0; // select(2) の返り値
  int lerrno;

  rb_hrtime_t *to, rel, end = 0; // タイムアウトの管理値
  timeout_prepare(&to, &rel, &end, set->timeout);
  // (timeout_prepare) set->timeoutがあればto, rel, endに値をセットする。なければ to = 0 にセットする

  volatile rb_hrtime_t endtime = end;

  // (fd_setを複製するマクロ)
  #define restore_fdset(dst, src) ((dst) ? rb_fd_dup(dst, src) : (void)0)

  // (read用のfd_set、write用のfd_set、excp用のfd_setをそれぞれ元のfd_setに更新するマクロ)
  #define do_select_update() (restore_fdset(set->rset, &set->orig_rset), \
                              restore_fdset(set->wset, &set->orig_wset), \
                              restore_fdset(set->eset, &set->orig_eset), \
                              TRUE)

  do {
    lerrno = 0; // エラーナンバーを初期化

    BLOCKING_REGION(
      set->th,
      {
        struct timeval tv;

        if (!RUBY_VM_INTERRUPTED(set->th->ec)) {
          result = native_fd_select(
            set->max,
            set->rset,
            set->wset,
            set->eset,
            rb_hrtime2timeval(&tv, to),
            set->th
          );

          if (result < 0) lerrno = errno;
        }
      },
      ubf_select,
      set->th,
      TRUE
    );

    // 割り込みチェック
    RUBY_VM_CHECK_INTS_BLOCKING(set->th->ec); /* may raise */
  } while (
    wait_retryable(&result, lerrno, to, endtime) // select(2) をリトライ可能かを確認、一時的なエラーであれば可能
    && do_select_update() // fd_setを準備
  );

  if (result < 0) errno = lerrno;

  return (VALUE)result;
}

static int
wait_retryable(volatile int *result, int errnum, rb_hrtime_t *rel, rb_hrtime_t end)
{
  int r = *result;

  if (r < 0) {
    switch (errnum) {
      case EINTR:
      #ifdef ERESTART
      case ERESTART:
      #endif
        *result = 0;
        if (rel && hrtime_update_expire(rel, end)) {
          *rel = 0;
        }
        return TRUE;
      }
      return FALSE;
    } else if (r == 0) {
    /* check for spurious wakeup */
    if (rel) {
      return !hrtime_update_expire(rel, end);
    }
    return TRUE;
  }
  return FALSE;
}
```
