# ps(1)
- 実行中のプロセスを表示

| オプション     | 効果                                       |
| -              | -                                          |
| オプションなし | 実行ユーザーが所有しているプロセスを表示   |
| `a`            | 端末に紐づく全てのプロセスを表示           |
| `x`            | 端末に紐づかないプロセス(デーモン)を表示   |
| `u`            | プロセスの所有者・CPU / メモリの状況を表示 |
| `f`            | 関連するプロセス同士をツリー上に表示       |

## プロセスの状態

| STAT | 意味                                   |
| -    | -                                      |
| R    | 実行可能状態                           |
| S    | スリープ状態                           |
| D    | 中断できないスリープ状態 (IO中など)    |
| T    | トレース用のシグナル等によって停止状態 |
| Z    | ゾンビ状態                             |
