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

// ...
void
rsock_init_socket_init(void)
{
  // ...
  rb_eSocket = rb_define_class("SocketError", rb_eStandardError);
  rb_eResolutionError = rb_define_class_under(rb_cSocket, "ResolutionError", rb_eSocket); // 追加
  // ...
}
```
