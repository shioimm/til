# `Addrinfo.getaddrinfo`の実装

```c
// ext/socket/raddrinfo.c

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
// ext/socket/raddrinfo.c

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
// ext/socket/raddrinfo.c

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
// ext/socket/raddrinfo.c

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

  // error = 0 か EAI_FAIL (Non-recoverable failure in name resolution) を返す
  error = numeric_getaddrinfo(hostp, portp, hints, &ai);

  if (error == 0) {
    res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    res->allocated_by_malloc = 1;
    res->ai = ai;
  } else {
    VALUE scheduler = rb_fiber_scheduler_current();
    int resolved = 0;

    if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
      // error = 0 か EAI_FAIL、もしくは EAI_NONAME (Hostname nor servname, or not known) を返す
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

      // error = 0 か EAI_NONAME、もしくはそれ以外の例外を表す数値を返す
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

    // getaddrinfo() で発生したエラーは rsock_raise_socket_error() へ渡される
    rsock_raise_socket_error("getaddrinfo", error);
  }

  return res;
}
```

```c
// ext/socket/init.c

void
rsock_raise_socket_error(const char *reason, int error)
{
#ifdef EAI_SYSTEM
  int e;
  // EAI_SYSTEM = System error returned in errno
  if (error == EAI_SYSTEM && (e = errno) != 0)
    rb_syserr_fail(e, reason);
#endif

#ifdef _WIN32
  rb_encoding *enc = rb_default_internal_encoding();
  VALUE msg = rb_sprintf("%s: ", reason);
  if (!enc) enc = rb_default_internal_encoding();
  rb_str_concat(msg, rb_w32_conv_from_wchar(gai_strerrorW(error), enc));
  rb_exc_raise(rb_exc_new_str(rb_eSocket, msg));

#else
  // 呼び出し: rsock_raise_socket_error("getaddrinfo", error);
  // errorに実際のエラーコードが格納されている
  rb_raise(rb_eSocket, "%s: %s", reason, gai_strerror(error));
#endif
```

```c
// ext/socket/getaddrinfo.c

#ifndef HAVE_GAI_STRERROR
#ifdef GAI_STRERROR_CONST
const
#endif
char *
gai_strerror(int ecode)
{
  if (ecode < 0 || ecode > EAI_MAX)
    ecode = EAI_MAX;
  return (char *)ai_errlist[ecode];
}
#endif
```

```c
// ext/socket/getaddrinfo.c

#ifndef HAVE_GAI_STRERROR
static const char *const ai_errlist[] = {
  "success.",
  "address family for hostname not supported.",    /* EAI_ADDRFAMILY */
  "temporary failure in name resolution.",         /* EAI_AGAIN      */
  "invalid value for ai_flags.",                   /* EAI_BADFLAGS   */
  "non-recoverable failure in name resolution.",   /* EAI_FAIL       */
  "ai_family not supported.",                      /* EAI_FAMILY     */
  "memory allocation failure.",                    /* EAI_MEMORY     */
  "no address associated with hostname.",          /* EAI_NODATA     */
  "hostname nor servname provided, or not known.", /* EAI_NONAME     */
  "servname not supported for ai_socktype.",       /* EAI_SERVICE    */
  "ai_socktype not supported.",                    /* EAI_SOCKTYPE   */
  "system error returned in errno.",               /* EAI_SYSTEM     */
  "invalid value for hints.",                      /* EAI_BADHINTS   */
  "resolved protocol is unknown.",                 /* EAI_PROTOCOL   */
  "unknown error.",                                /* EAI_MAX        */
};
#endif
```

```c
// error.c

void
rb_raise(VALUE exc, const char *fmt, ...)
{
  va_list args;
  va_start(args, fmt);
  rb_vraise(exc, fmt, args);
  va_end(args);
}

void
rb_vraise(VALUE exc, const char *fmt, va_list ap)
{
  rb_exc_raise(rb_exc_new3(exc, rb_vsprintf(fmt, ap)));
}
```

```c
// eval.c

/*!
 * Raises an exception in the current thread.
 * \param[in] mesg an Exception class or an \c Exception object.
 * \exception always raises an instance of the given exception class or
 *   the given \c Exception object.
 * \ingroup exception
 */
void
rb_exc_raise(VALUE mesg)
{
  rb_exc_exception(mesg, TAG_RAISE, Qundef);
}

static void
rb_exc_exception(VALUE mesg, int tag, VALUE cause)
{
  if (!NIL_P(mesg)) {
    mesg = make_exception(1, &mesg, FALSE);
  }
  rb_longjmp(GET_EC(), tag, mesg, cause);
}
```
