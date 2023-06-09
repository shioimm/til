# ptherad(3)

```c
#include <pthread.h>

pthread_t tid;

pthread_create(
  &tid,
  NULL,
  <生成するスレッドで実行する関数へのポインタ>,
  <生成するスレッドで実行する関数の引数となる変数アドレス>
);

pthread_join(
  tid,
  <生成したスレッドで実行した関数の返り値を格納するための変数アドレス>
);
```

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
```

### 条件変数

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mtx;
pthread_cond_t  cnd;
int x = 0; // 条件を表す変数

void write_a()
{
  while(x < 20) {
    pthread_mutex_lock(&mtx);
    x += 3;
    pthread_mutex_unlock(&mtx);
    printf("a: x = %d\n", x);
    if (x >= 10) pthread_cond_signal(&cnd); // xが10以上になったら合図を送る
    usleep(200000);
  }
}

void write_b()
{
  pthread_mutex_lock(&mtx);
  while(x < 10) pthread_cond_wait(&cnd, &mtx); // xが10未満の場合は合図を待つ
  puts("b: condition is now true");
  pthread_mutex_unlock(&mtx);
}

int main()
{
  pthread_t tid_a, tid_b;

  pthread_mutex_init(&mtx, NULL);
  pthread_cond_init(&cnd, NULL);

  pthread_create(&tid_a, NULL, (void *(*)(void *))write_a, &m);
  pthread_create(&tid_b, NULL, (void *(*)(void *))write_b, &m);

  pthread_join(tid_a, NULL);
  pthread_join(tid_b, NULL);

  return 0;
}

// Linuxによる並行プログラミング入門 P104
```
