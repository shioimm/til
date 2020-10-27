// Linuxとpthreadsによるマルチスレッドプログラミング入門 P174

#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

#define N_THREAD 4

int stopRequest;

void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec  = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

void *threadFunc(void *arg)
{
  int n = (int)arg;

  pthread_mutex_lock(&mutex);

  while (!stopRequest) {
    pthread_cond_wait(&cond, &mutex);
    printf("threadFunc%d: Got signal\n", n);
  }

  pthread_mutex_unlock(&mutex);
  return NULL;
}

int main()
{
  pthread_t threads[N_THREAD];
  int       i;

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&cond, NULL);
  stopRequest = 0;

  for (i = 0; i < N_THREAD; i++) {
    pthread_create(&threads[i], NULL, threadFunc, (void *)(i + 1));
  }

  mSleep(500);

  for (i = 0; i < 5; i++) {
    printf("main: Signal\n");
    pthread_cond_broadcast(&cond);
    mSleep((i + 1) * 100);
  }

  stopRequest = 1;

  for (i = 0; i < N_THREAD; i++) {
    pthread_join(threads[i], NULL);
  }

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);

  return 0;
}
