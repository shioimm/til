# ptherad(3)

```c
#include <pthread.h>

pthread_t tid;
int result;

int *fn(void *arg){
  int arg = (int)arg; など
  return arg;
}

pthread_create(
  &tid,
  NULL,     // スレッドの属性を指定する (NULL = デフォルトの属性)
  &fn,      // 生成するスレッドで実行する関数へのポインタ,
  (void*) 1 // 生成するスレッドで実行する関数の引数となる変数アドレス
);

// スレッドを待ち合わせる・待ち合わせたスレッドが終了したらそのスレッドコンテキストを破棄するようOSへ伝える
pthread_join(
  tid,
  &result // 生成したスレッドで実行した関数の返り値を格納するための変数アドレス
);

// 終了したスレッドを誤って使用しないよう、スレッドIDを格納していた変数はNULLで初期化しておく
tid = NULL;
```
