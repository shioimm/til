# `#<method>` -> `.c` -> 実行ファイル
1. prog.rb内にメソッド`#prog`を定義する
2. Cソースファイルmain.c内からprog.rbをファイルとして読み込む
3. main.c内から`#prog`をmrubyメソッドとして呼び出す
4. main.cをgccで実行ファイルmainへコンパイルする
5. 実行ファイルmainを実行する

```ruby
# prog.rb
def hello(name)
  "Hello #{name}"
end
```

```c
// main.c
#include <mruby.h>
#include <mruby/proc.h>
#include <mruby/compile.h>
#include <mruby/string.h>

int main()
{
  mrb_state *mrb = mrb_open();

  FILE *f = fopen("hello.rb", "r");
  mrb_load_file(mrb, f);
  fclose(f);

  mrb_value ret;
  ret = mrb_funcall(mrb, mrb_top_self(mrb), "hello", 1, mrb_str_new_cstr(mrb, "mruby") );

  mrb_p(mrb, ret);

  mrb_close(mrb);

  return 0;
}
```

```
$ gcc -Imruby/include/ main.c -o main mruby/build/host/lib/libmruby.a -lm
$ ./main
"Hello mruby"
```

## 参照
- [mrubyで書いたコードをC言語内で読み出す方法](https://shuzo-kino.hateblo.jp/entry/2013/10/24/224650)
