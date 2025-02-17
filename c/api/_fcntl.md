# `fcntl`

```c
#include <fcntl.h>

int fcntl(int fd, int cmd, ...);
```

| cmd               | 用途                                           | 成功時の返り値     |
| -                 | -                                              | -                  |
| `F_DUPFD`         | 既存のFDを複製する                             | 新しいFD値         |
| `F_DUPFD_CLOEXEC` | 既存のFDを複製しFDフラグ`FD_CLOEXEC`を設定する | 新しいFD値         |
| `F_GETFD`         | FDフラグの取得                                 | 対応するフラグ     |
| `F_SETFD`         | FDフラグの設定                                 |                    |
| `F_GETFL`         | ファイルステータスフラグの取得                 | 対応するフラグ     |
| `F_SETFL`         | ファイルステータスフラグの設定                 |                    |
| `F_GETOWN`        | 非同期入出力の所有者の取得                     | プロセスグループID |
| `F_SETOWN`        | 非同期入出力の所有者の設定                     |                    |
| `F_GETLK`         | レコードロックの取得                           |                    |
| `F_SETLK`         | レコードロックの設定                           |                    |
