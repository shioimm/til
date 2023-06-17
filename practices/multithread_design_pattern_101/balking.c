#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>

pthread_mutex_t mutex;

typedef struct {
  int number;
  int changed;
} Data;

Data data;

void *change()
{
  int n = 0;

  while (1) {
    if (data.changed) {
      puts("changed nothing");
      usleep(1);
    } else {
      data.number = n;

      pthread_mutex_lock(&mutex);
      data.changed = 1;
      pthread_mutex_unlock(&mutex);

      n++;
      printf("changed data: number = %d\n", data.number);
    }
  }

  return NULL;
}

void *save()
{
  while (1) {
    if (data.changed) {
      pthread_mutex_lock(&mutex);
      data.changed = 0;
      pthread_mutex_unlock(&mutex);

      printf("saved data: number = %d\n", data.number);
    } else {
      puts("saved nothing");
      usleep(1);
    }
  }

  return NULL;
}

int main()
{
  pthread_t changer, saver;

  pthread_mutex_init(&mutex, NULL);

  pthread_create(&changer, NULL, &change, NULL);
  pthread_create(&saver,   NULL, &save,   NULL);

  pthread_join(changer, NULL);
  pthread_join(saver,   NULL);

  pthread_mutex_destroy(&mutex);

  return 0;
}
