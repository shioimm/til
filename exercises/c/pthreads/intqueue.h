// Linuxとpthreadsによるマルチスレッドプログラミング入門 P248

#ifndef INTQUEUE_H
#define INTQUEUE_H

#include <stdlib.h>

typedef struct IntQueue_ IntQueue;

extern IntQueue *IntQueueCreate(size_t sz);             // szサイズのキューを生成
extern void     IntQueueDestroy(IntQueue *que);         // キューqueを削除
extern size_t   IntQueueGetSize(IntQueue *que);         // キューqueの最大要素を取得
extern size_t   IntQueueGetCount(IntQueue *que);        // キューqueの現在の登録要素数を取得
extern size_t   IntQueueGetFreeCount(IntQueue *que);    // キューque現在の空き要素数を取得
extern int      IntQueueAdd(IntQueue *que, int val);    // キューqueに要素valを追加
extern int      IntQueueGet(IntQueue *que, int *val);   // キューqueから要素を取り出しvalに格納
extern int      IntQueueWait(IntQueue *que, long msec); // キューqueに要素が追加されるまでmsec秒待つ

#endif /* INTQUEUE_H */
