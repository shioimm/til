// Linuxとpthreadsによるマルチスレッドプログラミング入門 P250

#include "intqueue.h"
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <stdio.h>

typedef struct IntQueue_ {
  int             *data;
  size_t          size;
  size_t          wp;
  size_t          rp;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;
} IntQueue;

IntQueue *IntQueueCreate(size_t sz)
{
  if (sz == 0) {
    return NULL;
  }

  IntQueue *que = (IntQueue *)malloc(sizeof(IntQueue));

  if (que == NULL) {
    return NULL;
  }

  que->size = sz + 1;
  que->data = (int *)malloc(que->size * sizeof(int));

  if (que->data == NULL) {
    free(que);
    return NULL;
  }

  que->wp = que->rp = 0;
  pthread_mutex_init(&que->mutex, NULL);
  pthread_cond_init(&que->cond, NULL);

  return que;
}

void IntQueueDestroy(IntQueue *que)
{
  if (que == NULL) {
    return;
  }

  free(que->data);
  pthread_mutex_destroy(&que->mutex);
  pthread_cond_destroy(&que->cond);
  free(que);
}

size_t IntQueueGetSize(IntQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  return que->size - 1;
}

size_t IntQueueGetCount(IntQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  size_t count;
  pthread_mutex_lock(&que->mutex);

  if (que->wp < que->rp) {
    count = que->size + que->wp - que->rp;
  } else {
    count = que->wp - que->rp;
  }

  pthread_mutex_unlock(&que->mutex);

  return count;
}

size_t IntQueueGetFreeCount(IntQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  return que->size - 1 - IntQueueGetCount(que);
}

int IntQueueAdd(IntQueue *que, int val)
{
  if (que == NULL) {
    return 0;
  }

  pthread_mutex_lock(&que->mutex);
  size_t next_wp = que->wp + 1;

  if (next_wp >= que->size) {
    next_wp -= que->size;
  }

  if (next_wp == que->size) {
    pthread_mutex_unlock(&que->mutex);
    return 0;
  }

  que->data[que->wp] = val;
  que->wp = next_wp;
  pthread_cond_signal(&que->cond);
  pthread_mutex_unlock(&que->mutex);

  return 1;
}

int IntQueueGet(IntQueue *que, int *val)
{
  if (que == NULL) {
    return 0;
  }

  pthread_mutex_lock(&que->mutex);

  if (que->rp == que->wp) {
    pthread_mutex_unlock(&que->mutex);
    return 0;
  }

  if (val != NULL) {
    *val = que->data[que->rp];
  }

  if (++(que->rp) >= que->size) {
    que->rp -= que->size;
  }

  pthread_mutex_unlock(&que->mutex);

  return 1;
}

int IntQueueWait(IntQueue *que, long msec)
{
  if (que == NULL) {
    return 0;
  }

  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  ts.tv_sec  += msec / 1000;
  ts.tv_nsec += (msec % 1000) * 1000000;

  if (ts.tv_nsec >= 1000000000) {
    ts.tv_sec++;
    ts.tv_nsec -= 1000000000;
  }

  while (que->wp == que->rp) {
    int err = pthread_cond_timedwait(&que->cond, &que->mutex, &ts);

    if (err == ETIMEDOUT) {
      break;
    } else if (err != 0) {
      fprintf(stderr, "Fatal error on pthread_cond_timedwait\n");
      exit(1);
    }
  }
  int res = (que->wp != que->rp);
  pthread_mutex_unlock(&que->mutex);

  return res;
}
