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

static ID id_error_code;

static VALUE
sock_resolv_error_code(VALUE self) {
  rb_ivar_set(self, id_error_code, rb_str_new_cstr("error code")); // FIXME
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
