// Linuxによる並行プログラミング入門 P106

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mtx;
pthread_cond_t  cnd;
int x = 0;

void write_a()
{
  while(x < 20) {
    pthread_mutex_lock(&mtx);

    x += 3;

    pthread_mutex_unlock(&mtx);

    printf("a: x = %d\n", x);

    if (x >= 10) pthread_cond_broadcast(&cnd);

    usleep(200000);
  }
}

void write_b()
{
  pthread_mutex_lock(&mtx);

  while(x < 10) pthread_cond_wait(&cnd, &mtx);

  puts("b: condition is now true");

  pthread_mutex_unlock(&mtx);
}

void write_c()
{
  pthread_mutex_lock(&mtx);

  while(x < 10) pthread_cond_wait(&cnd, &mtx);

  puts("c: condition is now true");

  pthread_mutex_unlock(&mtx);
}
int main()
{
  pthread_t tid_a, tid_b, tid_c;

  pthread_mutex_init(&mtx, NULL);
  pthread_cond_init(&cnd, NULL);

  pthread_create(&tid_a, NULL, (void *(*)(void *))write_a, &mtx);
  pthread_create(&tid_b, NULL, (void *(*)(void *))write_b, &mtx);
  pthread_create(&tid_c, NULL, (void *(*)(void *))write_c, &mtx);

  pthread_join(tid_a, NULL);
  pthread_join(tid_b, NULL);
  pthread_join(tid_c, NULL);

  return 0;
}
