# 関数定義

```c
// Rubyスクリプトから利用できる関数を定義する条件
// * 引数として mrb_state *mrb / mrb_value self をとること
// * mrb_value型を返すこと

static mrb_value mrb_my_uname(mrb_state *mrb, mrb_value self)
{
  struct utsname uts;
  mrb_value ret;

  if (uname(&uts) == -1) {
    mrb_sys_fail(mrb, "uname failed");
  }

  ret = mrb_str_new_cstr(mrb, uts.nondename);
  return ret;
}

// mrb_my_uname関数をFirstC#my_unameとして登録
void mrb_mruby_first_c_gem_init(mrb_state *mrb)
{
  struct RClass *firstc;
  firstc = mrb_define_class(mrb, "FirstC", mrb->object_class);
  mrb_define_class_method(mrb, firstc, "my_uname", mrb_my_uname, MRB_ARGS_NONE());
  DONE;
}
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
