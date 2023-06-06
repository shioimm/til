# `#include <unistd.h>`
#### `exec`関数群

| 関数名      | プログラム名 (p, _)          | コマンドライン引数 (v, l) | 環境 (e, _)      |
| -           | -                            | -                         | -                |
| `execv(2)`  | パスを指定                   | 配列で指定                | 自プロセスの環境 |
| `execve(2)` | パスを指定                   | 配列で指定                | 配列で指定       |
| `execvp(2)` | 環境変数$PATH + ファイル名   | 配列で指定                | 自プロセスの環境 |
| `execl(2)`  | パスを指定                   | 文字列リストで指定        | 自プロセスの環境 |
| `execle(2)` | パスを指定                   | 文字列リストで指定        | 配列で指定       |
| `execlp(2)` | 環境変数$PATH + ファイル名   | 文字列リストで指定        | 自プロセスの環境 |

```c
#include <unistd.h>

// execl(2)
execl("/usr/bin/echo", "echo", "foo", NULL);

char *argv[3];
argv[0] = "echo";
ergv[1] = "foo";
argv[2] = NULL;

// execv(2)
execv("/usr/bin/echo", argv);

// execvp(2)
execv("echo", argv); // 環境変数$PATHを探索する
```

## 参照
- 例解UNIX/Linuxプログラミング教室P185-224
- 詳解UNIXプログラミング第3版 7. プロセスの環境 / 8. プロセスの制御 / 9. プロセスの関係
- Linuxプログラミングインターフェース 6章
