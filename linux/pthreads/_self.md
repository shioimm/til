# スレッドID
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P18-17

## `pthread_self(3)`
- `pthread_self(3)`を呼び出したスレッドのIDを取得
```c
#include <pthread.h>

pthread_t pthread_self(void);
```
- スレッドID同士の比較のためには`pthread_equal(3)`を使用する

## `pthread_equal(3)`
- スレッドID同士が一致しているかどうかを比較する
```c
#include <pthread.h>

int pthread_equal(pthread_t t1, pthread_t t2);

// 同じ場合   - 0以外
// 異なる場合 - 0
```
