// Linuxとpthreadsによるマルチスレッドプログラミング入門 P148

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

void *tfunc()
{
  puts("thread: start");
  sleep(2);

  pthread_mutex_lock(&mutex);
  puts("thread: wait for signal");

  if (pthread_cond_wait(&cond, &mutex) != 0) {
    puts("thread: Error on pthread_cond_wait");
    exit(1);
  }

  puts("thread: got signal");
  pthread_mutex_unlock(&mutex);
  return NULL;
}

int main()
{
  pthread_t thread;

  pthread_mutex_init(&mutex);
  pthread_cond_init(&cond);
  pthread_create(&thread, NULL, tfunc, NULL);
  sleep(3);

  puts("main");

  pthread_cond_signal(&cond);
  pthread_join(thread, NULL);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&:cond);

  return 0;
}
