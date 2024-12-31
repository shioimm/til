# `Socker.tcp`

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

# Addrinfo.getaddrinfo
#   addrinfo_s_getaddrinfo
#   -> addrinfo_list_new
#   -> call_getaddrinfo
#   -> rsock_getaddrinfo
#   -> rb_getaddrinfo
#   -> fork_safe_do_getaddrinfo
#   -> getaddrinfo(2)
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
