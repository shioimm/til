```c
static VALUE
sock_connect_nonblock(VALUE sock, VALUE addr, VALUE ex)
{
  VALUE rai;
  rb_io_t *fptr;
  int n;

  SockAddrStringValueWithAddrinfo(addr, rai);
  addr = rb_str_new4(addr);

  // #define RB_IO_POINTER(obj,fp) rb_io_check_closed((fp) = RFILE(rb_io_taint_check(obj))->fptr)
  // rb_io_tへのポインタをfpに代入 -> それがクローズされていないかチェック
  GetOpenFile(sock, fptr);

  // static int
  // rb_fd_set_nonblock(int fd)
  // {
  //     #ifdef _WIN32
  //     return rb_w32_set_nonblock(fd);
  //     #elif defined(F_GETFL)
  //     int oflags = fcntl(fd, F_GETFL);
  //
  //     if (oflags == -1) return -1;
  //     if (oflags & O_NONBLOCK) return 0;
  //
  //     oflags |= O_NONBLOCK;
  //     return fcntl(fd, F_SETFL, oflags);
  //     #endif
  //
  //     return 0;
  // }
  rb_io_set_nonblock(fptr);

  n = connect(fptr->fd, (struct sockaddr*)RSTRING_PTR(addr), RSTRING_SOCKLEN(addr));

  if (n < 0) {
      int e = errno;
      if (e == EINPROGRESS) {
          if (ex == Qfalse) {
              return sym_wait_writable;
          }
          rb_readwrite_syserr_fail(RB_IO_WAIT_WRITABLE, e, "connect(2) would block");
      }
      if (e == EISCONN) {
          if (ex == Qfalse) {
              return INT2FIX(0);
          }
      }
      rsock_syserr_fail_raddrinfo_or_sockaddr(e, "connect(2)", addr, rai);
  }

  return INT2FIX(n);
}
```

```c
int
rsock_connect(VALUE self, const struct sockaddr *sockaddr, int len, int socks, VALUE timeout)
{
  int descriptor = rb_io_descriptor(self);
  rb_blocking_function_t *func = connect_blocking;
  struct connect_arg arg = {.fd = descriptor, .sockaddr = sockaddr, .len = len};

  rb_io_t *fptr;

  // struct connect_arg *arg = data;
  // return (VALUE)connect(arg->fd, arg->sockaddr, arg->len);
  RB_IO_POINTER(self, fptr);

  #if defined(SOCKS) && !defined(SOCKS5)
  if (socks) func = socks_connect_blocking;
  #endif

  // rb_thread_io_blocking_call(io, function, argument, events);
  int status = (int)rb_io_blocking_region(fptr, func, &arg);

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
          return wait_connectable(self, timeout);
    }
  }
  return status;
}
```

```c
VALUE
rb_thread_io_blocking_call(struct rb_io* io, rb_blocking_function_t *func, void *data1, int events)
{
  rb_execution_context_t *volatile ec = GET_EC();
  rb_thread_t *volatile th = rb_ec_thread_ptr(ec);

  RUBY_DEBUG_LOG("th:%u fd:%d ev:%d", rb_th_serial(th), io->fd, events);

  struct waiting_fd waiting_fd;
  volatile VALUE val = Qundef; /* shouldn't be used */
  volatile int saved_errno = 0;
  enum ruby_tag_type state;
  volatile bool prev_mn_schedulable = th->mn_schedulable;
  th->mn_schedulable = thread_io_mn_schedulable(th, events, NULL);

  int fd = io->fd;

  // `errno` is only valid when there is an actual error - but we can't
  // extract that from the return value of `func` alone, so we clear any
  // prior `errno` value here so that we can later check if it was set by
  // `func` or not (as opposed to some previously set value).
  errno = 0;

  thread_io_setup_wfd(th, fd, &waiting_fd);
  {
      EC_PUSH_TAG(ec);
      if ((state = EC_EXEC_TAG()) == TAG_NONE) {
          volatile enum ruby_tag_type saved_state = state; /* for BLOCKING_REGION */
        retry:
          BLOCKING_REGION(th, {
              val = func(data1);
              saved_errno = errno;
          }, ubf_select, th, FALSE);

          th = rb_ec_thread_ptr(ec);
          if (events &&
              blocking_call_retryable_p((int)val, saved_errno) &&
              thread_io_wait_events(th, fd, events, NULL)) {
              RUBY_VM_CHECK_INTS_BLOCKING(ec);
              goto retry;
          }
          state = saved_state;
      }
      EC_POP_TAG();

      th = rb_ec_thread_ptr(ec);
      th->mn_schedulable = prev_mn_schedulable;
  }
  /*
   * must be deleted before jump
   * this will delete either from waiting_fds or on-stack struct rb_io_close_wait_list
   */
  thread_io_wake_pending_closer(&waiting_fd);

  if (state) {
      EC_JUMP_TAG(ec, state);
  }
  /* TODO: check func() */
  RUBY_VM_CHECK_INTS_BLOCKING(ec);

  // If the error was a timeout, we raise a specific exception for that:
  if (saved_errno == ETIMEDOUT) {
      rb_raise(rb_eIOTimeoutError, "Blocking operation timed out!");
  }

  errno = saved_errno;

  return val;
}
```
