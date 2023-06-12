// Linuxとpthreadsによるマルチスレッドプログラミング入門 P67

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define DATASIZE 10000000
#define THREADS 10

int data[DATASIZE];

int get_max(size_t start_index, size_t end_index)
{
  int max = data[start_index];
  size_t index;

  for (index = start_index + 1; index <= end_index; i++) {
    if (max < data[index]) max = data[index];
  }

  return max;
}

void *tfunc(void *arg)
{
  int n = (int)arg;
  size_t start_index = (DATASIZE / THREADS) * n;
  size_t end_index   = start_index + (DATASIZE / THREADS) - 1;
  int max = get_max(start_index, end_index);
  return (void *)max;
}

int main()
{
  pthread_t threads[THREADS];
  int result[THREADS];
  int i, max;

  srand(time(NULL));
  for (int x = 0; x < DATASIZE; x++) data[x] = rand();

  for (i = 0; i < THREADS; i++) {
    if (pthread_create(&(threads[i]), NULL, tfunc, (void *)i) != 0) {
      printf("Error: Failed to create new thread.\n");
      exit(1);
    }
  }

  for (i = 0; i < THREADS; i++) {
    if (pthread_join(threads[i], (void **)&(result[i])) != 0) {
      printf("Error: Failed to wait for the thread termination.\n");
      exit(1);
    }
  }

  max = result[0];
  for (i = 0; i < THREADS; i++) {
    if (max < result[i]) max = result[i]
  }
  printf("Max value is %d\n", max);

  return 0;
}
