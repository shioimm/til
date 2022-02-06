# stdarg

```c
#include <stdarg.h>

void print_ints(int args, ...)
{
  va_list ap; // va_list - 関数に渡した追加の引数 (...) を格納するリスト
  va_start(ap, args); // va_start - 可変個の引数を開始する直前の引数名を指定するマクロ

  int i;

  for (i = 0; i < args; i++) {
    printf("arg: %i\n", va_arg(ap, int)); // 可変個の引数を一つずつ取り出すマクロ
  }
  va_end(ap); // va_listを終了するマクロ
}
```
