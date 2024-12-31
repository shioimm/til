# `Socker.tcp`

#### 名前解決
- `Addrinfo.foreach` -> `Addrinfo.getaddrinfo`
  - `addrinfo_s_getaddrinfo`
    - `addrinfo_list_new`
      - `call_getaddrinfo`
        - `rsock_getaddrinfo`
          - `rb_getaddrinfo`
            - `fork_safe_do_getaddrinfo`
             - `getaddrinfo(2)`

#### ソケット (Socketオブジェクト) の作成
- (`Addrinfo#connect` ->) `Socket.new`
  - `sock_initialize`
    - `rsock_socket`
      - `rsock_socket0`
        - `socket(2)`

#### 接続
- (`Addrinfo#connect` ->) `Socket#connect`
  - `sock_connect`
    - `rsock_connect`
      - `connect_blocking`
        - `connect(2)`

---

(2024/12/30)

```ruby
# Socket.tcp

def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket
  sock = if fast_fallback && !(host && ip_address?(host))
    tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
  else
    tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
  end

  if block_given?
    begin
      yield sock
    ensure
      sock.close
    end
  else
    sock
  end
end
```

```ruby
# Socket.tcp_without_fast_fallback

def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
  last_error = nil
  ret = nil

  local_addr_list = nil

  if local_host != nil || local_port != nil
    local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
  end

  Addrinfo.foreach(host, port, nil, :STREAM, timeout: resolv_timeout) {|ai|
    if local_addr_list
      local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
      next unless local_addr
    else
      local_addr = nil
    end

    begin
      sock = local_addr ?
        ai.connect_from(local_addr, timeout: connect_timeout) :
        ai.connect(timeout: connect_timeout)
    rescue SystemCallError
      last_error = $!
      next
    end
    ret = sock
    break
  }

  unless ret
    if last_error
      raise last_error
    else
      raise SocketError, "no appropriate local address"
    end
  end

  ret
end
```

```ruby
# Addrinfo.foreach

def self.foreach(nodename, service, family=nil, socktype=nil, protocol=nil, flags=nil, timeout: nil, &block)
  Addrinfo.getaddrinfo(nodename, service, family, socktype, protocol, flags, timeout: timeout).each(&block)
end
```

```c
// ext/socket/raddrinfo.c
// Addrinfo.getaddrinfo

void
rsock_init_addrinfo(void)
{
    // ...
    rb_define_singleton_method(rb_cAddrinfo, "getaddrinfo", addrinfo_s_getaddrinfo, -1);
    // ...
}

static VALUE
addrinfo_s_getaddrinfo(int argc, VALUE *argv, VALUE self)
{
    VALUE node, service, family, socktype, protocol, flags, opts, timeout;

    rb_scan_args(argc, argv, "24:", &node, &service, &family, &socktype,
                 &protocol, &flags, &opts);
    rb_get_kwargs(opts, &id_timeout, 0, 1, &timeout);
    if (timeout == Qundef) {
        timeout = Qnil;
    }

    return addrinfo_list_new(node, service, family, socktype, protocol, flags, timeout);
}

static VALUE
addrinfo_list_new(VALUE node, VALUE service, VALUE family, VALUE socktype, VALUE protocol, VALUE flags, VALUE timeout)
{
    VALUE ret;
    struct addrinfo *r;
    VALUE inspectname;

    struct rb_addrinfo *res = call_getaddrinfo(node, service, family, socktype, protocol, flags, 0, timeout);

    inspectname = make_inspectname(node, service, res->ai);

    ret = rb_ary_new();
    for (r = res->ai; r; r = r->ai_next) {
        VALUE addr;
        VALUE canonname = Qnil;

        if (r->ai_canonname) {
            canonname = rb_str_new_cstr(r->ai_canonname);
            OBJ_FREEZE(canonname);
        }

        addr = rsock_addrinfo_new(r->ai_addr, r->ai_addrlen,
                                  r->ai_family, r->ai_socktype, r->ai_protocol,
                                  canonname, inspectname);

        // VALUE
        // rsock_addrinfo_new(struct sockaddr *addr, socklen_t len,
        //                    int family, int socktype, int protocol,
        //                    VALUE canonname, VALUE inspectname)
        // {
        //     VALUE a;
        //     rb_addrinfo_t *rai;
        //
        //     a = addrinfo_s_allocate(rb_cAddrinfo);
        //     DATA_PTR(a) = rai = alloc_addrinfo();
        //     init_addrinfo(rai, addr, len, family, socktype, protocol, canonname, inspectname);
        //     return a;
        // }

        rb_ary_push(ret, addr);
    }

    rb_freeaddrinfo(res);
    return ret;
}

static struct rb_addrinfo *
call_getaddrinfo(VALUE node, VALUE service,
                 VALUE family, VALUE socktype, VALUE protocol, VALUE flags,
                 int socktype_hack, VALUE timeout)
{
    struct addrinfo hints;
    struct rb_addrinfo *res;

    MEMZERO(&hints, struct addrinfo, 1);
    hints.ai_family = NIL_P(family) ? PF_UNSPEC : rsock_family_arg(family);

    if (!NIL_P(socktype)) {
        hints.ai_socktype = rsock_socktype_arg(socktype);
    }
    if (!NIL_P(protocol)) {
        hints.ai_protocol = NUM2INT(protocol);
    }
    if (!NIL_P(flags)) {
        hints.ai_flags = NUM2INT(flags);
    }

    res = rsock_getaddrinfo(node, service, &hints, socktype_hack);

    if (res == NULL)
        rb_raise(rb_eSocket, "host not found");
    return res;
}

struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
    struct rb_addrinfo* res = NULL;
    struct addrinfo *ai;
    char *hostp, *portp;
    int error = 0;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;

    hostp = host_str(host, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(port, pbuf, sizeof(pbuf), &additional_flags);

    if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
        hints->ai_socktype = SOCK_DGRAM;
    }
    hints->ai_flags |= additional_flags;

    error = numeric_getaddrinfo(hostp, portp, hints, &ai);
    if (error == 0) {
        res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        res->allocated_by_malloc = 1;
        res->ai = ai;
    } else {
        VALUE scheduler = rb_fiber_scheduler_current();
        int resolved = 0;

        if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
            error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

            if (error != EAI_FAIL) {
                resolved = 1;
            }
        }

        if (!resolved) {
            error = rb_getaddrinfo(hostp, portp, hints, &ai);
            if (error == 0) {
                res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                res->allocated_by_malloc = 0;
                res->ai = ai;
            }
        }
    }

    if (error) {
        if (hostp && hostp[strlen(hostp)-1] == '\n') {
            rb_raise(rb_eSocket, "newline at the end of hostname");
        }
        rsock_raise_resolution_error("getaddrinfo", error);
    }

    return res;
}

static int
rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    int retry;
    struct getaddrinfo_arg *arg;
    int err = 0, gai_errno = 0;

start:
    retry = 0;

    arg = allocate_getaddrinfo_arg(hostp, portp, hints);
    if (!arg) {
        return EAI_MEMORY;
    }

    pthread_t th;
    if (raddrinfo_pthread_create(&th, fork_safe_do_getaddrinfo, arg) != 0) {
        int err = errno;
        free_getaddrinfo_arg(arg);
        errno = err;
        return EAI_SYSTEM;
    }
    pthread_detach(th);

    rb_thread_call_without_gvl2(wait_getaddrinfo, arg, cancel_getaddrinfo, arg);

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        if (arg->done) {
            err = arg->err;
            gai_errno = arg->gai_errno;
            if (err == 0) *ai = arg->ai;
        }
        else if (arg->cancelled) {
            retry = 1;
        }
        else {
            // If already interrupted, rb_thread_call_without_gvl2 may return without calling wait_getaddrinfo.
            // In this case, it could be !arg->done && !arg->cancelled.
            arg->cancelled = 1; // to make do_getaddrinfo call freeaddrinfo
            retry = 1;
        }
        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    if (need_free) free_getaddrinfo_arg(arg);

    // If the current thread is interrupted by asynchronous exception, the following raises the exception.
    // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
    rb_thread_check_ints();
    if (retry) goto start;

    /* Because errno is threadlocal, the errno value we got from the call to getaddrinfo() in the thread
     * (in case of EAI_SYSTEM return value) is not propagated to the caller of _this_ function. Set errno
     * explicitly, as round-tripped through struct getaddrinfo_arg, to deal with that */
    if (gai_errno) errno = gai_errno;
    return err;
}

static void *
fork_safe_do_getaddrinfo(void *ptr)
{
    return rb_thread_prevent_fork(do_getaddrinfo, ptr);
}

static void *
do_getaddrinfo(void *ptr)
{
    struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;

    int err, gai_errno;
    err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
    gai_errno = errno;
    #ifdef __linux__
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (err == EAI_SYSTEM && errno == ENOENT)
        err = EAI_NONAME;
    #endif

    int need_free = 0;

    rb_nativethread_lock_lock(&arg->lock);
    {
        arg->err = err;
        arg->gai_errno = gai_errno;
        if (arg->cancelled) {
            if (arg->ai) freeaddrinfo(arg->ai);
        }
        else {
            arg->done = 1;
            rb_native_cond_signal(&arg->cond);
        }
        if (--arg->refcount == 0) need_free = 1;
    }

    rb_nativethread_lock_unlock(&arg->lock);

    if (need_free) free_getaddrinfo_arg(arg);

    return 0;
}
```

```ruby
# Addrinfo#connect
def connect(timeout: nil, &block)
  connect_internal(nil, timeout, &block)
end

def connect_internal(local_addrinfo, timeout=nil) # :yields: socket
  sock = Socket.new(self.pfamily, self.socktype, self.protocol)

  begin
    sock.ipv6only! if self.ipv6?
    sock.bind local_addrinfo if local_addrinfo

    if timeout
      case sock.connect_nonblock(self, exception: false)
      when 0 # success or EISCONN, other errors raise
        break
      when :wait_writable
        sock.wait_writable(timeout) or
          raise Errno::ETIMEDOUT, 'user specified timeout'
      end while true
    else
      sock.connect(self)
    end
  rescue Exception
    sock.close
    raise
  end
  if block_given?
    begin
      yield sock
    ensure
      sock.close
    end
  else
    sock
  end
end
```

```c
// ext/socket/socket.c
// Socket#initialize
// Socket#connect

void
init_socket(void)
{
    //...
    rb_define_method(rb_cSocket, "initialize", sock_initialize, -1);
    // ...
    rb_define_method(rb_cSocket, "connect", sock_connect, 1);
    //...
}

// Socket#initialize ---

static VALUE
sock_initialize(int argc, VALUE *argv, VALUE sock)
{
    VALUE domain, type, protocol;
    int fd;
    int d, t;

    rb_scan_args(argc, argv, "21", &domain, &type, &protocol);
    if (NIL_P(protocol))
        protocol = INT2FIX(0);

    setup_domain_and_type(domain, &d, type, &t);
    fd = rsock_socket(d, t, NUM2INT(protocol));
    if (fd < 0) rb_sys_fail("socket(2)");

    return rsock_init_sock(sock, fd); // ソケットをSocketオブジェクトにする
}

int
rsock_socket(int domain, int type, int proto)
{
    int fd;

    fd = rsock_socket0(domain, type, proto);
    if (fd < 0) {
        if (rb_gc_for_fd(errno)) {
            fd = rsock_socket0(domain, type, proto);
        }
    }
    if (0 <= fd)
        rb_update_max_fd(fd);
    return fd;
}

static int
rsock_socket0(int domain, int type, int proto)
{
    #ifdef SOCK_CLOEXEC
    type |= SOCK_CLOEXEC;
    #endif

    #ifdef SOCK_NONBLOCK
    type |= SOCK_NONBLOCK;
    #endif

    int result = socket(domain, type, proto); // socket(2)

    if (result == -1)
        return -1;

    rb_fd_fix_cloexec(result);

    #ifndef SOCK_NONBLOCK
    rsock_make_fd_nonblock(result);
    #endif

    return result;
}

// Socket#connect ---

static VALUE
sock_connect(VALUE self, VALUE addr)
{
    VALUE rai;

    SockAddrStringValueWithAddrinfo(addr, rai);
    addr = rb_str_new4(addr);

    int result = rsock_connect(self, (struct sockaddr*)RSTRING_PTR(addr), RSTRING_SOCKLEN(addr), 0, RUBY_IO_TIMEOUT_DEFAULT);

    if (result < 0) {
        rsock_sys_fail_raddrinfo_or_sockaddr("connect(2)", addr, rai);
    }

    return INT2FIX(result);
}
```

```c
// ext/socket/init.c
int
rsock_connect(VALUE self, const struct sockaddr *sockaddr, int len, int socks, VALUE timeout)
{
    int descriptor = rb_io_descriptor(self);
    rb_blocking_function_t *func = connect_blocking;
    struct connect_arg arg = {.fd = descriptor, .sockaddr = sockaddr, .len = len};

    rb_io_t *fptr;
    RB_IO_POINTER(self, fptr);

    #if defined(SOCKS) && !defined(SOCKS5)
    if (socks) func = socks_connect_blocking;
    #endif
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

static VALUE
connect_blocking(void *data)
{
    struct connect_arg *arg = data;
    return (VALUE)connect(arg->fd, arg->sockaddr, arg->len);
}
```
