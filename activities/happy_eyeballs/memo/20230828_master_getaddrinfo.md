# `Addrinfo.getaddrinfo`の実装
https://github.com/ruby/ruby/blob/master/ext/socket/raddrinfo.c

```c
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
```

```c
static VALUE
addrinfo_list_new(
  VALUE node,
  VALUE service,
  VALUE family,
  VALUE socktype,
  VALUE protocol,
  VALUE flags,
  VALUE timeout
)
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

    rb_ary_push(ret, addr);
  }

  rb_freeaddrinfo(res);
  return ret;
}
```

```c
static struct rb_addrinfo *
call_getaddrinfo(
  VALUE node,
  VALUE service,
  VALUE family,
  VALUE socktype,
  VALUE protocol,
  VALUE flags,
  int socktype_hack,
  VALUE timeout
)
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
```

```c
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

  // error = 0 もしくは EAI_FAIL (Non-recoverable failure in name resolution) を返す
  error = numeric_getaddrinfo(hostp, portp, hints, &ai);

  if (error == 0) {
    res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    res->allocated_by_malloc = 1;
    res->ai = ai;
  } else {
    VALUE scheduler = rb_fiber_scheduler_current();
    int resolved = 0;

    if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
      // error = 0 もしくは EAI_FAIL / EAI_NONAME
      error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

      if (error != EAI_FAIL) {
        resolved = 1;
      }
    }

    if (!resolved) {
#ifdef GETADDRINFO_EMU
      error = getaddrinfo(hostp, portp, hints, &ai);
#else
      struct getaddrinfo_arg arg;
      MEMZERO(&arg, struct getaddrinfo_arg, 1);
      arg.node = hostp;
      arg.service = portp;
      arg.hints = hints;
      arg.res = &ai;

      // error = 0 もしくは EAI_NONAME
      error = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);
#endif
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
    rsock_raise_socket_error("getaddrinfo", error);
  }

  return res;
}
```
