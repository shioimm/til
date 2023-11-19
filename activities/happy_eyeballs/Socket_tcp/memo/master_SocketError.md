# masterの`rsock_raise_socket_error()`実装 (20231118時点)

```c
void
rsock_raise_socket_error(const char *reason, int error)
{
// EAI_SYSTEM = System error returned in errno
// getaddrinfo(3), getnameinfo(3) などのエラーコード

#ifdef EAI_SYSTEM

  int e;

  // EAI_SYSTEMの場合
  if (error == EAI_SYSTEM && (e = errno) != 0) {
    // rb_syserr_fail()
    //   1. eから適切なエラークラスを特定し、当該エラークラスのインスタンスを取得
    //   2. 取得したインスタンスを利用して例外を送出
    rb_syserr_fail(e, reason); // この行が実行された場合、そのままプログラムが終了する
  }


#endif
#ifdef _WIN32

  rb_encoding *enc = rb_default_internal_encoding();
  VALUE msg = rb_sprintf("%s: ", reason);
  if (!enc) enc = rb_default_internal_encoding();
  rb_str_concat(msg, rb_w32_conv_from_wchar(gai_strerrorW(error), enc));
  rb_exc_raise(rb_exc_new_str(rb_eSocket, msg));

#else

  // EAI_SYSTEM以外の場合
  rb_raise(rb_eSocket, "%s: %s", reason, gai_strerror(error));

#endif
}
```

## 使用箇所

```
ext/socket/rubysocket.h
311:NORETURN(void rsock_raise_socket_error(const char *, int));

ext/socket/init.c
40:rsock_raise_socket_error(const char *reason, int error)

ext/socket/raddrinfo.c
769:        rsock_raise_socket_error("getnameinfo", error);
978:        rsock_raise_socket_error("getaddrinfo", error);
1037:        rsock_raise_socket_error("getnameinfo", error);
1675:                    rsock_raise_socket_error("getnameinfo", error);
2043:            rsock_raise_socket_error("getnameinfo", error);
2389:        rsock_raise_socket_error("getnameinfo", error);

ext/socket/socket.c
1316:    rsock_raise_socket_error("getnameinfo", error);
```
