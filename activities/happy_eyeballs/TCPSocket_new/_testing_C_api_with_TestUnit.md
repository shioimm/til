# C APIのユニットテスト

```c
# ext/socket/raddrinfo.c
static VALUE
rb_getaddrinfo2(VALUE self)
{
    return rb_str_new_literal("OK");
}

/*
 * Addrinfo class
 */
void
rsock_init_addrinfo(void)
{
    // ...
    // 追加
    rb_define_singleton_method(rb_cAddrinfo, "rb_getaddrinfo2", rb_getaddrinfo2, 0);
    // ...
}
```

```c
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo2
  assert_equal "OK", Addrinfo.rb_getaddrinfo2
end
```
