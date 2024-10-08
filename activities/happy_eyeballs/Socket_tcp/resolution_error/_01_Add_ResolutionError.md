# `Socket::ResolutionError`を追加

```c
// ext/socket/rubysocket.h
// ...

extern VALUE rb_eSocket;
extern VALUE rb_eResolution; // 追加

// ...
```

```c
// ext/socket/init.c
// ...

VALUE rb_eSocket;
VALUE rb_eResolution; // 追加
static ID id_error_code;   // 追加

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
  rb_eResolution = rb_define_class_under(rb_cSocket, "ResolutionError", rb_eSocket);
  rb_define_method(rb_eResolution, "error_code", sock_resolv_error_code, 0);
  id_error_code = rb_intern_const("error_code");

  // ...
}
```
