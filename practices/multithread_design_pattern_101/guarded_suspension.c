// WIP
#include <stdio.h>
#include <pthread.h>

pthread_mutex_t m;
int storage = 0;
int condition = 0;

void *put_request()
{
  for (int i = 1; i <= 100; i++) {
    if (storage == 0) {
      storage = i;
      printf("clident requests no. %d\n", storage);
    } else {
      // 待つ
    }
  }

  return NULL;
}

void *get_request()
{
  int request;

  for (int i = 1; i <= 100; i++) {
    if (storage != 0) {
      request = storage;
      storage = 0;
      printf("server handles no. %d\n", request);
    } else {
      // 待つ
    }
  }

  return NULL;
}

int main()
{
  pthread_t client, server;

  pthread_mutex_init(&m, NULL);

  pthread_create(&client, NULL, &put_request, NULL);
  pthread_create(&server, NULL, &get_request, NULL);

  pthread_join(client, NULL);
  pthread_join(server, NULL);

  pthread_mutex_destroy(&m);

  return 0;
}
