// Linuxとpthreadsによるマルチスレッドプログラミング入門 P194

#include "6-1.h"
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

typedef struct {
  double x;
  double y;
} XYQueueItem;

struct XYQueue_ {
  XYQueueItem *data;
  size_t      size;
  size_t      wp;
  size_t      rp;
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
  return que;
}

void XYQueueDestroy(XYQueue *que)
{
  if (que == NULL) {
    return;
  }

  free(que->data);
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

  if (que->wp < que ->rp) {
    return que->size + que->wp - que->rp;
  } else {
    return que->wp - que->rp;
  }
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

  size_t next_wp = que->wp + 1;

  if (next_wp >= que->size) {
    next_wp -= que->size;
  }
  if (next_wp == que->rp) {
    return 0;
  }
  que->data[que->wp].x = x;
  que->data[que->wp].y = y;
  que->wp = next_wp;

  return 1;
}

int XYQueueGet(XYQueue *que, double *x, double *y)
{
  if (que == NULL) {
    return 0;
  }

  if (que->rp == que->wp) {
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

  return 1;
}

int XYQueueWait(XYQueue *que, long msec)
{
  if (que == NULL) {
    return 0;
  }

  while (1) {
    if (XYQueueGetCount(que) > 0) {
      break;
    }

    if (msec <= 0) {
      return 0;
    }

    mSleep(1);
    msec--;
  }
  return 1;
}
