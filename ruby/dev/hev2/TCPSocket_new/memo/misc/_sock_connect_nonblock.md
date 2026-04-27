# `sock_connect_nonblock`

```c
// ext/socket/socket.c

static VALUE
sock_connect_nonblock(
  VALUE sock, // Socket
  VALUE addr, // Addrinfo
  VALUE ex    // exception
) {
  VALUE rai;
  rb_io_t *fptr;
  int n;

  // SockAddrStringValueWithAddrinfo (ext/socket/rubysocket.h)
  //   -> rsock_sockaddr_string_value_with_addrinfo (ext/socket/raddrinfo.c)
  //      アドレス文字列オブジェクトaddrをRubyの文字列オブジェクトとしてraiに格納
  SockAddrStringValueWithAddrinfo(addr, rai);

  // アドレス文字列オブジェクトaddrを保存
  addr = rb_str_new4(addr);

  // GetOpenFile (include/ruby/io.h)
  //   -> RB_IO_POINTER (include/ruby/io.h) - Queries the underlying IO pointer.
  // sockの内部情報へのポインタをfptrに格納
  GetOpenFile(sock, fptr);
  // fptrをノンブロッキングモードに設定
  rb_io_set_nonblock(fptr);

  // connect(2)
  n = connect(fptr->fd, (struct sockaddr*)RSTRING_PTR(addr), RSTRING_SOCKLEN(addr));

  if (n < 0) {
    int e = errno;
    if (e == EINPROGRESS) { // 接続中
      if (ex == Qfalse) { // exception: false
        // 例外を起こさず:wait_writableを返す
        return sym_wait_writable;
      }

      // exception: true (デフォルト)
      rb_readwrite_syserr_fail(RB_IO_WAIT_WRITABLE, e, "connect(2) would block");
    }
    if (e == EISCONN) { // 接続済み
      if (ex == Qfalse) { // exception: false
        // 例外を起こさず0を返す
        return INT2FIX(0);
      }
    }
    // exception: true (デフォルト)
    rsock_syserr_fail_raddrinfo_or_sockaddr(e, "connect(2)", addr, rai);
  }

  // 接続に成功 (0を返す)
  return INT2FIX(n);
}
```
