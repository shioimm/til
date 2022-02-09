# signal
```c
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

void bye(int sig) // シグナルハンドラとなる関数
{
  puts("bye\n");
  exit(1);
}

int catch_signal(int sig, void (*handler)(int))
{
  // sigaction構造体の作成
  struct sigaction action;
  action.sa_handler = handler;
  sigemptyset(&action.sa_mask);
  action.sa_flags = 0;

  // sigactionの登録
  return sigaction(sig, &action, NULL);
}

int main()
{
  if (catch_signal(SIGINT, bye) == -1) {
    fprintf(stderr, "Can't set handler");
    exit(2);
  }

  char name[20];
  printf("name: ");
  fgets(name, 30, stdin);
  printf("Hello %s\n", name);

  return 0;
}
```

```c
// sigaction構造体 - シグナルハンドラのラッパーとなる構造体

struct sigaction {
  void     (*sa_handler)(int);
  void     (*sa_sigaction)(int, siginfo_t *, void *);
  sigset_t   sa_mask;  // ハンドラ実行中に禁止すべきシグナルのマスク
  int        sa_flags; // 追加のフラグ
  void     (*sa_restorer)(void);
};

int sigaction(int sig, const struct sigaction *restrict act, struct sigaction *restrict oact);
```
