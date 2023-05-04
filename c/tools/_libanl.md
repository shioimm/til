# libanl (glibc拡張)
#### `getaddrinfo_a(3)`
- 非同期で名前解決を行う`getaddrinfo(3)`拡張
- `getaddrinfo_a(3)`内部でスレッドを起動し、スレッド内で`getaddrinfo(3)`を実行する

```c
#define _GNU_SOURCE
#include <netdb.h>

int getaddrinfo_a(
  int mode,             // GAI_WAIT (同期) もしくはGAI_NOWAIT (非同期)
  struct gaicb *list[], // gaicb構造体のリスト
  int nitems,           // listの大きさ
  struct sigevent *sevp // sigevent構造体
);
```

```c
struct gaicb {
  const char            *ar_name;    // ホスト名
  const char            *ar_service; // サービス
  const struct addrinfo *ar_request; // ヒント
  struct addrinfo       *ar_result;  // 結果を格納するバッファ
};
```

```c
#include <signal.h>

struct sigevent {
  int    sigev_notify;                          // Notification method
  int    sigev_signo;                           // Notification signal
  union sigval sigev_value;                     // Data passed with notification
  void (*sigev_notify_function) (union sigval); // Function used for thread notification (SIGEV_THREAD)
  void  *sigev_notify_attributes;               // Attributes for notification thread (SIGEV_THREAD)
  pid_t  sigev_notify_thread_id;                // ID of thread to signal (SIGEV_THREAD_ID); Linux-specific
};
```
