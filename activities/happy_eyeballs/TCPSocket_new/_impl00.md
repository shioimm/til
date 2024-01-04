# 実装1
- とりあえずC APIのテストの準備をした

```c
# ext/socket/raddrinfo.c
static VALUE
rb_getaddrinfo2(VALUE self)
{
    return rb_str_new_literal("OK");
}

static VALUE
rb_getaddrinfo2_test(VALUE self)
{
    return rb_getaddrinfo2(self);
}

void
rsock_init_addrinfo(void)
{
    // ...
    // 追加
    rb_define_singleton_method(rb_cAddrinfo, "rb_getaddrinfo2_test", rb_getaddrinfo2_test, 0);
    // ...
}
```

```c
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo2_test
  assert_equal "OK", Addrinfo.rb_getaddrinfo2_test
end
```
