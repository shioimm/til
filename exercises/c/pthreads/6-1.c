// Linuxとpthreadsによるマルチスレッドプログラミング入門 P194

#include "6-1.h"
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <stdio.h>

typedef struct {
  double x;
  double y;
} XYQueueItem;

struct XYQueue_ {
  XYQueueItem     *data;
  size_t          size;
  size_t          wp;
  size_t          rp;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;
};

static void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec  = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

XYQueue *XYQueueCreate(size_t sz)
{
  if (sz == 0) {
    return NULL;
  }

  XYQueue *que = (XYQueue *)malloc(sizeof(XYQueue));

  if (que == NULL) {
    return NULL;
  }

  que->size = sz + 1;
  que->data = (XYQueueItem *)malloc(que->size * sizeof(XYQueueItem));

  if (que->data == NULL) {
    free(que);
    return NULL;
  }

  que->wp = que->rp = 0;
  pthread_mutex_init(&que->mutex, NULL);
  pthread_cond_init(&que->cond,   NULL);

  return que;
}

void XYQueueDestroy(XYQueue *que)
{
  if (que == NULL) {
    return;
  }

  free(que->data);
  pthread_mutex_destroy(&que->mutex);
  pthread_cond_destroy(&que->cond);
  free(que);
}

size_t XYQueueGetSize(XYQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  return que->size - 1;
}

size_t XYQueueGetCount(XYQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  size_t count;
  pthread_mutex_lock(&que->mutex);

  if (que->wp < que ->rp) {
    count = que->size + que->wp - que->rp;
  } else {
    count = que->wp - que->rp;
  }

  pthread_mutex_unlock(&que->mutex);

  return count;
}

size_t XYQueueGetFreeCount(XYQueue *que)
{
  if (que == NULL) {
    return 0;
  }

  return que->size - 1 - XYQueueGetCount(que);
}

int XYQueueAdd(XYQueue *que, double x, double y)
{
  if (que == NULL) {
    return 0;
  }

  pthread_mutex_lock(&que->mutex);

  size_t next_wp = que->wp + 1;

  if (next_wp >= que->size) {
    next_wp -= que->size;
  }
  if (next_wp == que->rp) {
    pthread_mutex_unlock(&que->mutex);
    return 0;
  }
  que->data[que->wp].x = x;
  que->data[que->wp].y = y;
  que->wp = next_wp;

  pthread_cond_signal(&que->cond);
  pthread_mutex_unlock(&que->mutex);

  return 1;
}

int XYQueueGet(XYQueue *que, double *x, double *y)
{
  if (que == NULL) {
    return 0;
  }

  pthread_mutex_lock(&que->mutex);

  if (que->rp == que->wp) {
    pthread_mutex_unlock(&que->mutex);
    return 0;
  }

  if (x != NULL) {
    *x = que->data[que->rp].x;
  }

  if (y != NULL) {
    *y = que->data[que->rp].y;
  }

  if (++(que->rp) >= que->size) {
    que->rp -= que->size;
  }

  pthread_mutex_unlock(&que->mutex);

  return 1;
}

int XYQueueWait(XYQueue *que, long msec)
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

  pthread_mutex_lock(&que->mutex);

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
