// Thread Per Message + Consumer-Producer

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;

typedef struct {
  pthread_cond_t cond;
} Cond;

Cond client_cond;
Cond worker_conds[5];

typedef struct {
  int no;
  int taken;
} Request;

Request reqests[100];
int working_size = 0; // テーブルサイズ

void *put()
{
  for (int i = 0; i < 100; i++) {
    pthread_mutex_lock(&mutex);
    if (working_size >= 5) pthread_cond_wait(&client_cond.cond, &mutex);

    reqests[i].no = i;
    reqests[i].taken = 0;
    working_size++;
    printf("client put no. %d\n", i);
    printf("%d\n", working_size);

    pthread_mutex_unlock(&mutex);
    usleep(1);
  }

  return NULL;
}

int main()
{
  pthread_t client;
  pthread_t workers[5];

  pthread_mutex_init(&mutex, NULL);

  pthread_cond_init(&client_cond.cond, NULL);

  pthread_create(&client, NULL, &put, NULL);
  // for (int i = 0; i < 5; i++) pthread_create(&workers[i], NULL, &take, (void *)i);
  // for (int i = 0; i < 5; i++) pthread_join(workers[i], NULL);

  pthread_join(client, NULL);
  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&client_cond.cond);

  return 0;
}
