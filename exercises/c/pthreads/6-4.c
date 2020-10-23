// Linuxとpthreadsによるマルチスレッドプログラミング入門 P209

#include "6-1.h"
#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_THREAD     1000
#define QUEUE_SIZE   10000
#define REPEAT_COUNT 10

int stopRequest;

void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec  = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

double randDouble(double minValue, double maxValue)
{
  return minValue + (double)rand() / ((double)RAND_MAX + 1) * (maxValue - minValue);
}

void *enqueue(void *arg)
{
  XYQueue *que = (XYQueue *)arg;
  double  x;
  int     i;

  for (i = 0; i < REPEAT_COUNT; i++) {
    x = randDouble(0, 10000);

    if (!XYQueueAdd(que, x, x)) {
      printf("Failed to XYQueueAdd\n");
    }

    mSleep(rand() % 100);
  }
  return NULL;
}

void *dequeue(void *arg)
{
  XYQueue *que = (XYQueue *)arg;
  double  x, y;

  while (!stopRequest) {
    if (XYQueueWait(que, 100)) {
      if (!XYQueueGet(que, &x, &y)) {
        printf("Failed to XYQueueWait\n");
        continue;
      }
      if (x != y) {
        printf("Oops! Invalid que data (%f != %f)\n", x, y);
      }
    }
  }

  return NULL;
}

int main()
{
  XYQueue   *que;
  pthread_t enqueueThread[N_THREAD];
  pthread_t dequeueThread;
  int       i;

  if ((que = XYQueueCreate(QUEUE_SIZE)) == NULL) {
    printf("Failed to create queue\n");
    exit(1);
  }

  if (pthread_create(&dequeueThread, NULL, dequeue, (void *)que) != 0) {
    printf("Failed to create dequeueThread\n");
    exit(1);
  }

  for (i = 0; i < N_THREAD; i++) {
    if (pthread_create(&enqueueThread[i], NULL, enqueue, (void *)que) != 0) {
      printf("Failed to create enqueueThread[%d]\n", i);
      exit(1);
    }
  }

  for (i = 0; i < N_THREAD; i++) {
    if (pthread_join(enqueueThread[i], NULL) != 0) {
      printf("Failed to create enqueueThread[%d]\n", i);
      exit(1);
    }
  }

  stopRequest = 1;

  if (pthread_join(dequeueThread, NULL) != 0) {
    printf("Failed to create dequeueThread\n");
    exit(1);
  }

  XYQueueDestroy(que);

  return 0;
}
