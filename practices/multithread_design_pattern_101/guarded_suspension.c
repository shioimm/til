#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;
int storage[100];

void *put_request()
{
  for (int i = 1; i <= 100; i++) {
    pthread_mutex_lock(&mutex);

    storage[i] = i;
    printf("client requests no. %d\n", storage[i]);

    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mutex);
    usleep(1);
  }

  return NULL;
}

void *get_request()
{
  int request;

  for (int i = 1; i <= 100; i++) {
    pthread_mutex_lock(&mutex);

    if (storage[i] == 0) pthread_cond_wait(&cond, &mutex);

    request = storage[i];
    storage[i] = 0;

    printf("server handles no. %d\n", request);
    pthread_cond_signal(&cond);

    pthread_mutex_unlock(&mutex);
  }

  return NULL;
}

int main()
{
  pthread_t client, server;

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&cond, NULL);

  pthread_create(&client, NULL, &put_request, NULL);
  pthread_create(&server, NULL, &get_request, NULL);

  pthread_join(client, NULL);
  pthread_join(server, NULL);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);

  return 0;
}
