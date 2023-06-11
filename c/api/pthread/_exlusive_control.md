# 排他制御
### Mutex

```c
#include <pthread.h>

pthread_mutex_t m;

pthread_mutex_init(&m, NULL);

// Mutexを取得しようとした際、
// すでに別スレッドによってpthread_mutex_lock()実行済みの場合は
// そのスレッドによってpthread_mutex_unlock()が実行されるまで
// 待機状態になる
pthread_mutex_lock(m);
pthread_mutex_unlock(m);

// Mutexを取得しようとした際、
// すでに別スレッドによってpthread_mutex_lock()実行済みの場合は非ゼロ、
// そうでない場合はゼロを返す
pthread_mutex_trylock(m);

// main関数を修了する前に削除
pthread_mutex_destroy(m);
```

### 条件変数

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

void *tfunc()
{
  pthread_mutex_lock(&mutex);
  pthread_cond_wait(&cond, &mutex); // シグナルを待つ
  puts("thread: got the signal);    // シグナルを補足したら実行
  pthread_mutex_unlock(&mutex);
}

int main()
{
  pthread_t thread;
  int x = 0; // 条件を表す変数

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&cond, NULL);
  pthread_create(&thread, NULL, &tfunc, &m); // 別スレッドを起動

  while(x < 10) {
    x++;
    printf("main: x = %d\n", x);

    if (x >= 5) pthread_cond_signal(&cond); // xが5以上になったら条件変数へシグナルを送る

    usleep(200000);
  }

  pthread_join(thread, NULL);

  return 0;
}

// Linuxによる並行プログラミング入門 P104
```

#### `pthread_cond_wait()`の動作
1. (ユーザーが明示的にMutexをロックする)
2. 条件変数を偽にする
2. Mutexをアンロックする
3. 条件変数が真になるまで待つ
4. 条件変数が真になったらMutexをロックして任意の処理を行う
5. (ユーザーが明示的にMutexをアンロックする)
