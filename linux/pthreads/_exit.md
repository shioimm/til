# スレッドの終了
- 参照: Linuxとpthreadsによるマルチスレッドプログラミング入門 P18-17

## スレッドの終了条件
- スレッド実行関数がreturnされた場合
- プロセスが終了した場合
  - プロセス内の全てのスレッドが強制終了する
  - `pthread_join(3)` - 全てのスレッドの終了を待ち合わせてからプロセスを終了する
- スレッド実行関数からさらに別の関数を呼び出し、その先では`pthread_exit(3)`が呼ばれた場合

## スレッドコンテキスト
- OSがスレッドの状態を保持するためのメモリ
  - スレッドの返り値を含む
- OSはスレッドの実行が終了した後もスレッドコンテキストを持ち続ける


## スレッドの返り値
- スレッド実行関数がreturnされた際の返り値
- `pthread_exit(3)`の返り値

## `pthread_exit(3)`
```c
#include <pthread.h>

void pthread_exit(void *value_ptr);
```
#### `void *value_ptr`
- スレッドの返り値

## `pthread_join(3)`
- スレッドの終了待ちを行う
- スレッドの終了後、スレッドコンテキストの破棄を行う
  - スレッドIDを格納していた変数はスレッドコンテキストの破棄後`NULL`を代入する
```c
#include <pthread.h>

int pthread_join(pthread_t thread, void **value_ptr);

// 成功 - 0
// 失敗 - 0以外
// 指定したスレッドが終了するまで返ってこない
// pthread_joinが呼ばれる前にスレッド実行関数が終了していた場合pthread_joinはすぐに返ってくる
```
#### `pthread_t thread`
- 作成されたスレッドID(`pthread_t`型)

#### `void **value_ptr`
- スレッドの返り値を格納するアドレス
