// Linuxとpthreadsによるマルチスレッドプログラミング入門 P190

#ifndef XYQUEUE_H
#define XYQUEUE_H

#include <stdlib.h>

typedef struct XYQueue_ XYQueue;

extern XYQueue *XYQueueCreate(size_t sz);         // success キューへのポインタ / fail NULL
extern void    XYQueueDestroy(XYQueue *que);
extern size_t  XYQueueGetSize(XYQueue *que);      // 最大要素数
extern size_t  XYQueueGetCount(XYQueue *que);     // 登録要素数
extern size_t  XYQueueGetFreeCount(XYQueue *que); // 空き要素数
extern int     XYQueueAdd(XYQueue *que, double x, double y); // success 1 / fail 0
extern int     XYQueueGet(XYQueue *que, double *x, double *y); // success 1 / fail 0
extern int     XYQueueWait(XYQueue *que, long msec);         // success 1 / timedout 0

#endif /* XYQUEUE_H */
