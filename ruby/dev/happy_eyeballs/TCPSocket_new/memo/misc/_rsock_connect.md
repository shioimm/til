# `rsock_connect`

```c
// ext/socket/init.c

int
rsock_connect(
  int fd,
  const struct sockaddr *sockaddr,
  int len,
  int socks,
  struct timeval *timeout
) {
  int status;

  // static VALUE
  // connect_blocking(void *data)
  // {
  //   struct connect_arg *arg = data;
  //   return (VALUE)connect(arg->fd, arg->sockaddr, arg->len);
  // }
  rb_blocking_function_t *func = connect_blocking;

  struct connect_arg arg;

  arg.fd = fd;
  arg.sockaddr = sockaddr;
  arg.len = len;

  // ...

  // BLOCKING_REGION_FD (ext/socket/rubysocket.h)
  //   -> rb_thread_io_blocking_region (thread.c)
  //     -> rb_thread_io_blocking_call (thread.c) ブロッキングIOを行う操作の呼び出し
  status = (int)BLOCKING_REGION_FD(func, &arg);

  if (status < 0) {
    switch (errno) {
      case EINTR:

      #ifdef ERESTART
      case ERESTART:
      #endif

      case EAGAIN:

      #ifdef EINPROGRESS
      case EINPROGRESS:
      #endif

        // wait_connectable (ext/socket/init.c)
        // ブロッキングモードでのconnect(2)をエミュレートする
        // (EINTRで中断された場合やノンブロッキングモードでの呼び出しでもブロッキングモードのように動作する)
        return wait_connectable(fd, timeout);
    }
  }
  return status;
}
```

- `connect(2)`をブロッキングモードのように呼び出し、その実行結果をintとして返す