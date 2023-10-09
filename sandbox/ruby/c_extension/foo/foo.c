// 1. このファイルを作成
// 2. extconf.rbを作成
// 3. $ ruby extconf.rb -> Makefileが作成される
// 4. $ make -> 共有ライブラリ.bundle (.so) が作成される
// 5. ライブラリを使用したいファイルでrequireする

#include "ruby.h"

static VALUE
foo_len(VALUE self, VALUE arg)
{
  return rb_funcall(arg, rb_intern("size"), 0, 0);
}

void
Init_foo(void)
{
  VALUE cFoo = rb_define_class("Foo", rb_cObject);
  rb_define_method(cFoo, "len", foo_len, 1);
}
