# タスクスケジューリング
- スケジューリングの変更にはroot権限が必要
- スケジューリングポリシーは`SCHED_FIFO`、`SCHED_RR`、`SCHED_OTHER`のいずれかを設定可能
- 優先度は`SCHED_FIFO`または`SCHED_RR`の場合は1 (低) - 99 (高) を設定可能 (`SCHED_OTHER`は0のみ)
- デフォルトではポリシーは`SCHED_OTHER`、優先度は0

```c
#include <pthread.h>

pthread_t tid;
struct sched_param sched;

sched.sched_priority = 2; // 優先度の設定
pthread_setschedparam(tid, SCHED_FIFO, &sched); // schedにスケジューリングポリシーを設定

int policy;

pthread_getschedparam(tid, &policy, &sched); // スケジューリングポリシーをpolicy, 優先度をschedに格納
```
