# `Socket::ResolutionError`

```c
// ext/socket/rubysocket.h
// ...

extern VALUE rb_eSocket;
extern VALUE rb_eResolutionError; // 追加

// ...
```

```c
// ext/socket/init.c
// ...

VALUE rb_eSocket;
VALUE rb_eResolutionError; // 追加
static ID id_error_code;   // 追加

// 変更
void
rsock_raise_socket_error(const char *reason, int error)
{
#ifdef EAI_SYSTEM
  int e;
  if (error == EAI_SYSTEM && (e = errno) != 0)
      rb_syserr_fail(e, reason);
#endif
#ifdef _WIN32
  rb_encoding *enc = rb_default_internal_encoding();
  VALUE msg = rb_sprintf("%s: ", reason);
  if (!enc) enc = rb_default_internal_encoding();
  rb_str_concat(msg, rb_w32_conv_from_wchar(gai_strerrorW(error), enc));
#else
  VALUE msg = rb_sprintf("%s: %s", reason, gai_strerror(error));
#endif

  StringValue(msg);
  VALUE self = rb_class_new_instance(1, &msg, rb_eResolutionError);
  rb_ivar_set(self, id_error_code, INT2NUM(error));
  rb_exc_raise(self);
}

// 追加
static VALUE
sock_resolv_error_code(VALUE self)
{
  return rb_attr_get(self, id_error_code);
}

// ...
void
rsock_init_socket_init(void)
{
  // ...
  rb_eSocket = rb_define_class("SocketError", rb_eStandardError);

  // 追加
  rb_eResolutionError = rb_define_class_under(rb_cSocket, "ResolutionError", rb_eSocket);
  rb_define_method(rb_eResolutionError, "error_code", sock_resolv_error_code, 0);

  // ...
}
```
