// スレッド数を限定したThread Per Message + スレッド間通信にConsumer-Producerを使用
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;

typedef struct {
  pthread_cond_t cond;
} Cond;

Cond client_cond;
Cond worker_cond;

typedef struct {
  int no;
  int ready;
  int taken;
} Request;

Request requests[100];
int working_size = 0; // テーブルサイズ
int stop = 0;

void *put()
{
  for (int i = 0; i < 100; i++) {
    pthread_mutex_lock(&mutex);
    if (working_size >= 5) pthread_cond_wait(&client_cond.cond, &mutex);

    requests[i].no = i;
    requests[i].ready = 1;
    requests[i].taken = 0;
    working_size++;
    printf("client puts no. %d\n", i);
    pthread_cond_broadcast(&worker_cond.cond);

    pthread_mutex_unlock(&mutex);
  }

  return NULL;
}

void *take(void *arg)
{
  int no = (int )arg;

  for (int i = 0; i < 100; i++) {
    pthread_mutex_lock(&mutex);
    if (requests[i].ready == 0) pthread_cond_wait(&worker_cond.cond, &mutex);

    if (requests[i].taken == 0) {
      printf("worker %d takes no. %d\n", no, requests[i].no);
      requests[i].taken = 1;
      working_size--;
      pthread_cond_signal(&client_cond.cond);
    }

    pthread_mutex_unlock(&mutex);
  }

  return NULL;
}

int main()
{
  pthread_t client;
  pthread_t workers[5];

  pthread_mutex_init(&mutex, NULL);

  pthread_cond_init(&client_cond.cond, NULL);
  pthread_cond_init(&worker_cond.cond, NULL);

  pthread_create(&client, NULL, &put, NULL);
  for (int i = 0; i < 100; i++) requests[i].ready = 0;
  for (int i = 0; i < 5; i++) pthread_create(&workers[i], NULL, &take, i);

  pthread_join(client, NULL);
  for (int i = 0; i < 5; i++) pthread_join(workers[i], NULL);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&client_cond.cond);

  return 0;
}
