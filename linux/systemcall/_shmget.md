# shmget(2)
- System V 共有メモリセグメントを割り当てる

```c
#include <sys/ipc.h>
#include <sys/shm.h>

struct memory {
  char msg[80];
} *m;

key_t  key;
int    shmid;

key   = ftok("<ファイルパス>", '<キー文字>');      // キーを取得
shmid = shmget(key, sizeof(struct memory), IPC_CREAT | 0666); // 共有メモリを確保

p = shmat(shmid, NULL, 0); // 共有メモリを自プロセスに追加

strcpy(p->msg, <書き込み内容>)

shmdt(p);                   // 共有メモリを自プロセスから切り離す
shmctl(shmid, IPC_RMID, 0); // 共有メモリを削除
```

```
$ ipcs  -m       # 存在する共有メモリの確認
$ ipcrm -m ***** # 共有メモリの削除
```
