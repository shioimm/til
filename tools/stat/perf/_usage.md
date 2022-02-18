# Usage
#### stat
- イベントカウントを取得する

```
$ sudo perf stat 計測するプログラム

# (詳細なカウンタの値を表示する)
$ sudo perf stat -d 計測するプログラム

# 計測するプログラムをプロセスIDで指定する
$ sudo perf stat -p プロセスID

# ホスト全体の計測
$ sudo perf stat -a
$ sudo perf stat -a sleep 10 # 所定の時間の間計測する
```

| 項目                    | 意味                                              |
| -                       |-                                                  |
| task-clock              | OSが実行プロセスに割り振った実行時間(ms)          |
| context-switches        | コンテキストが切り替わった回数                    |
| cpu-migrations          | CPUを移動した回数                                 |
| page-faults             | ページフォルトが発生した回数                      |
| cycles                  | 使用したCPUサイクル数                             |
| stalled-cycles-frontend | フロントエンドで命令が止まったサイクル数(CPU依存) |
| stalled-cycles-backend  | バックエンドで命令が止まったサイクル数(CPU依存)   |
| instructions            | リタイアした命令数                                |
| branches                | 分岐命令の実行回数                                |
| branch-misses           | 分岐予測をミスした回数                            |

#### top
- ライブイベントのカウントを確認する↲

```
# 実行しているプログラムの統計情報を動的に表示する
$ sudo perf top 計測したいプログラム --stdio
```

#### top
- 実行中のプログラムの統計情報をリアルタイムで表示する

```
$ sudo perf top -a --stdio
```

#### record / report
- record - イベントを記録し`perf.data`に出力・表示する
- report - プロセスや関数によりイベントを分解す

```
# 実行しているプログラムの統計情報の詳細をperf.dataに蓄積する
$ sudo perf record 計測したいプログラム

# perf.dataを出力する
$ sudo perf report --stdio

# (コールグラフを表示)
$ sudo perf report -g --stdio
```

## e.g. Apache HTTPサーバーのCPUを計測する
1. 計測するサーバーのワーカープロセスのpidを確認 (`$ ps aux | grep apache`)
2. `perf`で計測を開始する (`$ sudo perf stat -p 対象のpid`)
3. Apache Benchでワークロードを発生させる (`$ ab -n 20000 -c 10 対象のホスト名`)
4. `2`で計測していたパフォーマンスカウンタの集計結果を確認

## 参照・引用
- [perf　パフォーマンス測定　その１](https://ameblo.jp/softwaredeveloper/entry-11967982906.html)
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
