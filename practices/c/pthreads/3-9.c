// Linuxとpthreadsによるマルチスレッドプログラミング入門 P67

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>


#define DATASIZE 10000000
#define THREADS 10

int data[DATASIZE];

void setRandomData()
{
  int i;
  for (i = 0; i < DATASIZE; i++) {
    data[i] = rand();
  }
}

int getMax(size_t startIndex, size_t endIndex)
{
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
  size_t startIndex = (DATASIZE / THREADS) * n;
  size_t endIndex   = startIndex + (DATASIZE / THREADS) - 1;
  int max = getMax(startIndex, endIndex);

  return (void *)max;
}

int main()
{
  pthread_t threads[THREADS];
  int res[THREADS];
  int i, max;

  srand(time(NULL));
  setRandomData();

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
