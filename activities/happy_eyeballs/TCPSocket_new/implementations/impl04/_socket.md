# 11/23-

```c
ID tcp_fast_fallback;

VALUE socket_s_tcp_fast_fallback(VALUE self) {
    return rb_ivar_get(rb_cSocket, tcp_fast_fallback);
}

VALUE socket_s_tcp_fast_fallback_set(VALUE self, VALUE value) {
    rb_ivar_set(rb_cSocket, tcp_fast_fallback, value);
    return value;
}

void
Init_socket(void)
{
    // ...

    tcp_fast_fallback = rb_intern_const("tcp_fast_fallback");
    rb_ivar_set(rb_cSocket, tcp_fast_fallback, Qtrue);

    // ...
    rb_define_singleton_method(rb_cSocket, "tcp_fast_fallback", socket_s_tcp_fast_fallback, 0);
    rb_define_singleton_method(rb_cSocket, "tcp_fast_fallback=", socket_s_tcp_fast_fallback_set, 1);

    // ...
}
```
