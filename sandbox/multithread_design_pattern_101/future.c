#include <stdio.h>
#include <pthread.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

typedef struct {
  int ready;
  int data;
} Future;

Future *ready(void *arg)
{
  Future *f = (Future *)arg;

  pthread_mutex_lock(&mutex);

  if (f->ready == 0) pthread_cond_wait(&cond, &mutex);
  f->data = 1;
  puts("ready");

  pthread_mutex_unlock(&mutex);

  return f;
}

int main()
{
  pthread_t woker1, woker2;

  Future future = { 0, 0 };
  Future *result;

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&cond, NULL);

  pthread_create(&woker1, NULL, &ready, &future);

  pthread_mutex_lock(&mutex);
  future.ready = 1;
  pthread_cond_signal(&cond);
  pthread_mutex_unlock(&mutex);

  pthread_join(woker1, (void **)&result);
  printf("Data %d\n", result->data);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);

  return 0;
}
