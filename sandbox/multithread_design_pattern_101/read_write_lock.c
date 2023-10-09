// データの参照中はロックを取らず、データの変更中はロックを取る

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

typedef struct {
  int number;
  int is_reading;
  int is_writing;
} Data;

Data data;

void *do_read(void *arg)
{
  int n = (int)arg;

  while (1) {
    pthread_mutex_lock(&mutex);

    if (data.is_writing) pthread_cond_wait(&cond, &mutex);

    data.is_reading = 1;
    printf("Reader %d reads data: %d\n", n, data.number);
    data.is_reading = 0;

    pthread_mutex_unlock(&mutex);
  }

  return NULL;
}

void *do_write(void *arg)
{
  int n = (int)arg;
  int count = 0;

  while (1) {
    pthread_mutex_lock(&mutex);

    if (data.is_reading || data.is_writing) pthread_cond_wait(&cond, &mutex);

    data.is_writing = 1;
    data.number = count;
    printf("Writer %d writes data: %d\n", n, data.number);
    data.is_writing = 0;
    count++;

    pthread_mutex_unlock(&mutex);

    usleep(1);
  }

  return NULL;
}

int main()
{
  pthread_t reader1, reader2, writer1, writer2;

  data.number     = 0;
  data.is_reading = 0;
  data.is_writing = 0;

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&cond, NULL);

  pthread_create(&reader1, NULL, &do_read,  (void *)1);
  pthread_create(&reader2, NULL, &do_read,  (void *)2);
  pthread_create(&writer1, NULL, &do_write, (void *)1);
  pthread_create(&writer2, NULL, &do_write, (void *)2);

  pthread_join(reader1, NULL);
  pthread_join(reader2, NULL);
  pthread_join(writer1, NULL);
  pthread_join(writer2, NULL);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);

  return 0;
}
