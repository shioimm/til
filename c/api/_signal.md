# `#include <signal.h>`

```c
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

void handler(int sig) // シグナルハンドラとなる関数
{
  printf("Signal %d is catched.\n", sig);
  exit(1);
}

int catch_signal(int sig, void (*handler)(int))
{
  // シグナル動作 (sigaction構造体) の作成
  struct sigaction action;
  action.sa_handler = handler;
  action.sa_flags   = 0;        // シグナルハンドラの動作を変更するためのフラグの集合
  sigemptyset(&action.sa_mask); // sa_maskを空に初期化する

  return sigaction(sig, &action, NULL); // シグナルsigに対してsigactionを登録
}

int main()
{
  if (catch_signal(SIGINT, handler) == -1) exit(2)

  char text[20];
  fgets(text, 30, stdin);
  printf("%s\n", text);

  return 0;
}
```

```c
// sigaction構造体 - シグナルハンドラのラッパーとなる構造体

struct sigaction {
  void     (*sa_handler)(int);
  void     (*sa_sigaction)(int, siginfo_t *, void *);
  sigset_t   sa_mask;  // シグナルを受け取らずにマスクする対象のシグナルの集合
  int        sa_flags; // 追加のフラグ
  void     (*sa_restorer)(void);
};

int sigaction(int sig, const struct sigaction *restrict act, struct sigaction *restrict oact);
```

### 例外処理

```c
#include <signal.h>

sigjmp_buf env;
int flag = 0;

sigsetjmp(&env, 1);
siglongjmp(&env, flag);
```
