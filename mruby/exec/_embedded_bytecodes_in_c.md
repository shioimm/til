# `.rb` -> `.c` -> 実行ファイル
1. prog.rbををmrbcコマンドでCソースファイルprog.c (`prog`関数) へコンパイルする
2. Cソースファイルmain.cの中から`prog`関数を呼び出す
3. main.cとprog.cをgccでリンクし実行ファイルmainへコンパイルする
4. 実行ファイルmainを実行する

```ruby
# prog.rb
mruby = 'mruby'
p mruby + ' ' + 'program'
```

```
$ bin/mrbc -Bbytecodes prog.rb # => prog.c
```

```c
// prog.c
#include <stdint.h>
#ifdef __cplusplus
extern
#endif
const uint8_t bytecodes[] = {
  // 略
};
```

```c
// main.c
#include <mruby.h>
#include <mruby/irep.h>
#include "prog.c"

int main()
{
  mrb_state *mrb = mrb_open();
  if (!mrb) { /* handle error */ }
  mrb_load_irep(mrb, bytecodes);
  mrb_close(mrb);
  return 0;
}
```

```
$ gcc -std=c99 -Imruby/include main.c -o main mruby/build/host/lib/libmruby.a -lm # => main*
$ ./main # => "mruby program"
```

- [Executing Ruby code with mruby](https://mruby.org/docs/articles/executing-ruby-code-with-mruby.html)
