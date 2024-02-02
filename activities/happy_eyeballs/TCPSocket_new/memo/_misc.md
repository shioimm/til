#### `rsock_syserr_fail_host_port`

```c
// ext/socket/socket.c

// エラーメッセージつきで例外を発生させる
void
rsock_syserr_fail_host_port(int err, const char *mesg, VALUE host, VALUE port)
{
  VALUE message;
  message = rb_sprintf("%s for %+" PRIsVALUE " port % " PRIsVALUE "", mesg, host, port);
  // e.g.
  //   mesg = "Error"
  //   host = "localhost"
  //   port = 80 の場合、
  //   "Error for localhost port 80"

  if (err == ETIMEDOUT) {
    rb_exc_raise(rb_exc_new3(rb_eIOTimeoutError, message));
  }

  rb_syserr_fail_str(err, message);
}

// error.c

void
rb_syserr_fail_str(int e, VALUE mesg)
{
  rb_exc_raise(rb_syserr_new_str(e, mesg));
}

// rb_exc_raise - 現在のスレッドで例外を発生させる (longjump)
// rb_syserr_new_str - eからシステムエラーを取得し、エラークラスのインスタンスをつくる
```
