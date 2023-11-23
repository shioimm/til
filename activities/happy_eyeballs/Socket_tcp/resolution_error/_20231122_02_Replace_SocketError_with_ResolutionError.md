# `rsock_raise_socket_error`のSocketErrorをSocket::ResolutionErrorで置き換える

```c
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
```
