// Linuxとpthreadsによるマルチスレッドプログラミング入門 P72

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>


#define DATASIZE 10000000
#define THREADS 10

int data[DATASIZE];

typedef struct {
  size_t startIndex;
  size_t endIndex;
} ThreadContext;

void setRandomData()
{
  int i;
  for (i = 0; i < DATASIZE; i++) {
    data[i] = rand();
  }
}

int getMax(ThreadContext *ctx)
{
  int max = data[ctx->startIndex];
  size_t index;

  for (index = ctx->startIndex + 1; index <= ctx->endIndex; index++) {
    if (max < data[index]) {
      max = data[index];
    }
  }

  return max;
}

void *threadFunc(void *arg)
{
  int n = (int)arg;
  ThreadContext ctx;
  ctx.startIndex = (DATASIZE / THREADS) * n;
  ctx.endIndex   = ctx.startIndex + (DATASIZE / THREADS) - 1;
  int max = getMax(&ctx);

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
