// Linuxとpthreadsによるマルチスレッドプログラミング入門 P69

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>


#define DATASIZE 10000000
#define THREADS 10

int data[DATASIZE];

pthread_key_t startIndexKey;
pthread_key_t endIndexKey;

void setRandomData()
{
  int i;
  for (i = 0; i < DATASIZE; i++) {
    data[i] = rand();
  }
}

int getMax()
{
  size_t startIndex = (size_t)pthread_getspecific(startIndexKey);
  size_t endIndex   = (size_t)pthread_getspecific(endIndexKey);

  int max = data[startIndex];
  size_t index;

  for (index = startIndex + 1; index <= endIndex; index++) {
    if (max < data[index]) {
      max = data[index];
    }
  }

  return max;
}

void *threadFunc(void *arg)
{
  int n = (int)arg;

  pthread_setspecific(startIndexKey, (void *)((DATASIZE / THREADS) * n));
  pthread_setspecific(endIndexKey,   (void *)((DATASIZE / THREADS) - 1));

  int max = getMax();

  return (void *)max;
}

int main()
{
  pthread_t threads[THREADS];
  int res[THREADS];
  int i, max;

  srand(time(NULL));
  setRandomData();

  pthread_key_create(&startIndexKey, NULL);
  pthread_key_create(&endIndexKey,   NULL);

  for (i = 0; i < THREADS; i++) {
    if (pthread_create(&(threads[i]), NULL, threadFunc, (void *)i) != 0) {
      printf("Error: Failed to create new thread\n");
      exit(1);
    }
  }

  for (i = 0; i < THREADS; i++) {
    if (pthread_join(threads[i], (void **)&(res[i])) != 0) {
      printf("Error: Failed to wait for thread termination\n");
      exit(1);
    }
  }

  max = res[0];

  for (i = 0; i < THREADS; i++) {
    if (max < res[i]) {
      max = res[i];
    }
  }

  printf("Max value is %d\n", max);

  return 0;
}
