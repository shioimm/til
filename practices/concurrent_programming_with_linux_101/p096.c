// Linuxによる並行プログラミング入門 P96

#include <stdio.h>
#include <pthread.h>

void write_a(pthread_mutex_t *m)
{
  int i;

  pthread_mutex_lock(m);
  for (i = 1; i <= 3; i++) printf("a%d\n", i);
  pthread_mutex_unlock(m);
}

void write_b(pthread_mutex_t *m)
{
  int i;

  pthread_mutex_lock(m);
  for (i = 1; i <= 3; i++) printf("b%d\n", i);
  pthread_mutex_unlock(m);
}

int main()
{
  pthread_t tid_a, tid_b;
  pthread_mutex_t m;

  pthread_mutex_init(&m, NULL);

  pthread_create(&tid_a, NULL, (void *(*)(void *))write_a, &m);
  pthread_create(&tid_b, NULL, (void *(*)(void *))write_b, &m);

  pthread_join(tid_a, NULL);
  pthread_join(tid_b, NULL);

  return 0;
}
