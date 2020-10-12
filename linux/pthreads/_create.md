# スレッドの開始
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P16-17

## スレッドの返り値
- スレッド実行関数がreturnされた際の返り値
- `pthread_exit(3)`の返り値

## `pthread_create(3)`
```c
#include <pthread.h>

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);

// 成功 - 0
// 失敗 - 0以外
// 新しいスレッドの作成後、スレッドの終了を待つことなく返ってくる
```
#### `pthread_t *thread`
- 作成するスレッドID(`pthread_t`型)を格納するアドレス

#### `const pthread_attr_t *attr`
- 作成するスレッドの属性を指定する
  - `pthread_attr_init(3)`
  - `pthread_attr_setdetachstate(3)`
  - `pthread_attr_setstacksize(3)`など
- OSやライブラリのバージョンなどにより正しく機能しない場合がある
- デフォルトは`NULL`

#### `void *(*start_routine)(void *)`
- 作成するスレッドで実行する関数

#### `void *arg`
- `start_routine`の引数になる関数
