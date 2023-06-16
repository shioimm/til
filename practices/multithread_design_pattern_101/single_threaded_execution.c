#include <stdio.h>
#include <pthread.h>

pthread_mutex_t m;
int number;

typedef struct {
  int count;
} data;

void *add(void *arg)
{
  data *d = (data *)arg;

  for (int i = 0; i < d->count; i++) {
    pthread_mutex_lock(&m);
    number = number + 1;
    pthread_mutex_unlock(&m);
  }
  return NULL;
}

int main()
{
  pthread_t threads[4];
  data arg_data[4];

  for (int i = 0; i < 4; i++) arg_data[i].count = 2500;

  pthread_mutex_init(&m, NULL);

  for (int i = 0; i < 4; i++) pthread_create(&threads[i], NULL, &add, &arg_data[i]);
  for (int i = 0; i < 4; i++) pthread_join(threads[i], NULL);

  printf("expect 10000 / actual %d\n", number);
  pthread_mutex_destroy(&m);

  return 0;
}
