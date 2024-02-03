# `rsock_connect`

```c
// ext/socket/init.c

int
rsock_connect(int fd, const struct sockaddr *sockaddr, int len, int socks, struct timeval *timeout)
{
  int status;
  rb_blocking_function_t *func = connect_blocking;
  struct connect_arg arg;

  arg.fd = fd;
  arg.sockaddr = sockaddr;
  arg.len = len;

  #if defined(SOCKS) && !defined(SOCKS5)
  if (socks) func = socks_connect_blocking;
  #endif

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

        return wait_connectable(fd, timeout);
    }
  }
  return status;
}
```
