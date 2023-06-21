// 動作しているスレッドを終了処理を実行した上で終了させる
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;
int is_shutdown_requested = 0;

void *count(void *count)
{
  puts("started to count");

  while (!is_shutdown_requested) {
    pthread_mutex_lock(&mutex);
    *count++;
    pthread_mutex_unlock(&mutex);
    usleep(10);
  }

  puts("shutdown requested");
  pthread_exit(count);
}

void *terminate()
{
  for (int i = 0; i < 100; i++) usleep(1);
  is_shutdown_requested = 1;
  return NULL;
}

int main()
{
  pthread_t counter, terminator;

  pthread_create(&counter,    NULL, &count,     0);
  pthread_create(&terminator, NULL, &terminate, NULL);

  int count;
  pthread_join(counter,    &count);
  pthread_join(terminator, NULL);

  printf("count: %d\n", count);

  return 0;
}
