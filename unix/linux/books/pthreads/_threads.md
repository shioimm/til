# スレッドの管理
## TL;DR
- スレッドの管理
  - `pthread_create(3)` - スレッド生成
  - `pthread_exit(3)`  - 現在のスレッド終了
  - `pthread_join(3)`  - スレッドの終了待ち
  - `pthread_self(3)`  - 自身のスレッドIDを得る
  - `pthread_equal(3)` - スレッドIDが等しいか調べる

## スレッドの開始
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P16-17

### `pthread_create(3)`
```c
#include <pthread.h>

int pthread_create(pthread_t            *thread,
                   const pthread_attr_t *attr,
                   void                 *(*start_routine)(void *),
                   void                 *arg);

// 成功 - 0
// 失敗 - 0以外
// 新しいスレッドの作成後、スレッドの終了を待つことなく返ってくる
```
- `pthread_t *thread`
  - 作成するスレッドID(`pthread_t`型)を格納するアドレス
- `const pthread_attr_t *attr`
  - 作成するスレッドの属性を指定する
    - `pthread_attr_init(3)`
    - `pthread_attr_setdetachstate(3)`
    - `pthread_attr_setstacksize(3)`など
  - OSやライブラリのバージョンなどにより正しく機能しない場合がある
  - デフォルトは`NULL`
- `void *(*start_routine)(void *)`
  - 作成するスレッドで実行する関数
- `void *arg`
  - `start_routine`の引数になる関数

## スレッドの終了
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P18-17

### `pthread_exit(3)`
```c
#include <pthread.h>

void pthread_exit(void *value_ptr);
```
- `void *value_ptr`
  - スレッドの返り値

### `pthread_join(3)`
- スレッドの終了待ちを行う
- スレッドの終了後、スレッドコンテキストの破棄を行う
  - スレッドIDを格納していた変数はスレッドコンテキストの破棄後`NULL`を代入する
```c
#include <pthread.h>

int pthread_join(pthread_t   thread,
                 void      **value_ptr);

// 成功 - 0
// 失敗 - 0以外
// 指定したスレッドが終了するまで返ってこない
// pthread_joinが呼ばれる前にスレッド実行関数が終了していた場合pthread_joinはすぐに返ってくる
```
- `pthread_t thread`
  - 作成されたスレッドID(`pthread_t`型)
- `void **value_ptr`
  - スレッドの返り値を格納するアドレス

### `pthread_cancel(3)`
- スレッドから別のスレッドに停止要求を出す
  - 対象のスレッドはOSに制御が渡り次第、自動的に`pthread_exit(3)`を発行して停止する
  - スレッドが消去されてもリソースの解放は行われない
  - `pthread_cancel(3)`は対象のスレッドの終了を待たない
```c
#include <pthread.h>

int pthread_cancel(pthread_t thread);

// 成功 - 0
// 失敗 - 0以外
// 実行後、対象のスレッドの終了を待つことなくすぐに返る
```

## スレッドID
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P18-17

### `pthread_self(3)`
- `pthread_self(3)`を呼び出したスレッドのIDを取得
```c
#include <pthread.h>

pthread_t pthread_self(void);
```
- スレッドID同士の比較のためには`pthread_equal(3)`を使用する

### `pthread_equal(3)`
- スレッドID同士が一致しているかどうかを比較する
```c
#include <pthread.h>

int pthread_equal(pthread_t t1,
                  pthread_t t2);

// 同じ場合   - 0以外
// 異なる場合 - 0
```
