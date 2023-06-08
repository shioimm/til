# msgget(2)
- System V メッセージキュー識別子を取得する

```c
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>

struct msbbuf {
  long mtype;
  char mtext[80];
};

key_t  key;
int    queid;
struct msbbuf msg;

key   = ftok("<ファイルパス>", '<キー文字>'); // キーを取得
queid = msgget(key, 0666 | IPC_CREAT);        // メッセージキューを作成

msg.mtype = <PID>;
msgsnd(queid, &msg, strlen(msg.mtext), 0); // メッセージキューへメッセージを送信
msgrcv(queid, &msg, 80, 1, 0);             // メッセージキューからメッセージを受信
msgctl(queid, IPC_RMID, 0);                // メッセージキューを削除
```

```
$ ipcs  -q       # 存在するメッセージキュープロセスの確認
$ ipcrm -q ***** # メッセージキューの削除
```
