# PR#4247の実装
- https://github.com/ruby/ruby/blob/5a396f186eb98d093552d0bee67db01745e06945/ext/socket/init.c
  - `Socket::Constants::EAI_ADDRFAMILY` (Address family for hostname not supported) と
    `Socket::Constants::EAI_AGAIN` (Temporary failure in name resolution) を捕捉したい
  - いずれの定数も現状 `Socket.getaddrinfo` `Addrinfo.getaddrinfo` などの内部でSocketErrorに変換されている

```c
static ID id_error_code;

// ...

void
rsock_init_socket_init(void)
{
  /*
   * SocketError is the error class for socket.
   */

  // SocketError クラスに initialize、error_code、== メソッドを追加

  rb_eSocket = rb_define_class("SocketError", rb_eStandardError);
  rb_define_method(rb_eSocket, "initialize", sockerr_initialize, -1);
  rb_define_method(rb_eSocket, "error_code", sockerr_error_code, 0);
  rb_define_method(rb_eSocket, "==", sockerr_equal, 1);
  // ...

  id_error_code = rb_intern_const("error_code");

  // ...
}
```

```c
/*
 * call-seq:
 *   SocketError.new(msg, error_code = nil)  -> SocketError
 *
 * The error code is subsequently available via the #error_code method.
 */

// 引数はCの配列として第二引数に入れて渡される
static VALUE
sockerr_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE mesg, error;

  // 長さ argc の配列 argv をフォーマット "02" に従って解析し、
  // Rubyのメソッドに渡される第一引数 &mesg と第二引数 &error に書き込む
  rb_scan_args(argc, argv, "02", &mesg, &error);

  // super() : 第一引数は引数数、第二引数は引数の値
  rb_call_super(1, &mesg);

  // SocketError オブジェクトの属性 id_error_code に error を代入
  if (!NIL_P(error)) { rb_ivar_set(self, id_error_code, error); }

  return self;
}
```

```c
/*
 * call-seq:
 *   socket_error.error_code -> integer
 *
 * Return this SocketError's error code.
 */

static VALUE
sockerr_error_code(VALUE self) {
  // 属性id_error_codeにセットした値を取得
  return rb_attr_get(self, id_error_code);
}
```

```c
/*
 * call-seq:
 *   socket_error === other  -> true or false
 *
 * Return +true+ if no errno is set, or
 * if the error numbers +self+ and _other_ are the same.
 */

static VALUE
sockerr_equal(VALUE self, VALUE exc)
{
  if (!rb_obj_is_kind_of(exc, rb_eSocket)) {
    if (!rb_respond_to(exc, id_error_code)) return Qfalse;
  }

  // super(exc) が偽ではない場合
  if (RTEST(rb_call_super(1, &exc))) {
    VALUE self_num, exc_num;

    // レシーバのエラーコードを取得
    self_num = rb_attr_get(self, id_error_code);
    if (NIL_P(self_num)) { self_num = rb_funcallv(self, id_error_code, 0, 0); }

    // 比較対象のオブジェクトのエラーコードを取得
    exc_num = rb_attr_get(exc, id_error_code);
    if (NIL_P(exc_num)) { exc_num = rb_funcallv(exc, id_error_code, 0, 0); }

    // レシーバと比較対象のオブジェクトのエラーコードを比較
    if (self_num == exc_num) { return Qtrue; }
  }

  return Qfalse;
}
```

```c
void
rsock_raise_socket_error(const char *reason, int error)
{
  VALUE socket_error, msg; // 追加
  VALUE argv[2];           // 追加

#ifdef EAI_SYSTEM

  int e;
  if (error == EAI_SYSTEM && (e = errno) != 0)
  rb_syserr_fail(e, reason);

#endif
#ifdef _WIN32

  rb_encoding *enc = rb_default_internal_encoding();
  msg = rb_sprintf("%s: ", reason);
  if (!enc) enc = rb_default_internal_encoding();
  rb_str_concat(msg, rb_w32_conv_from_wchar(gai_strerrorW(error), enc));

#else

  msg = rb_sprintf("%s: %s", reason, gai_strerror(error)); // 追加

#endif
  // 追加
  argv[0] = msg;
  argv[1] = INT2NUM(error);

  socket_error = rb_class_new_instance(2, argv, rb_eSocket);
  rb_exc_raise(socket_error);
}
```
