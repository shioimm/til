# `$ sudo perf stat`
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

#### e.g. Apache HTTPサーバーのCPUを計測
```
# ターミナル1
$ ps aux | grep apache # ワーカープロセスのpidを確認
$ sudo perf stat -p <ワーカープロセスのpid>

# ターミナル2
$ ab -n 20000 -c 10 <URI>

# ターミナル1
# ターミナル2でのabの終了後、Ctrl+C

 Performance counter stats for process id '32525':

       1375.592144      task-clock (msec)         #    0.020 CPUs utilized
             29612      context-switches          #    0.022 M/sec
                49      cpu-migrations            #    0.036 K/sec
              7095      page-faults               #    0.005 M/sec
   <not supported>      cycles
   <not supported>      instructions
   <not supported>      branches
   <not supported>      branch-misses

      69.086759252 seconds time elapsed
```

## 参照・引用
- [perf　パフォーマンス測定　その１](https://ameblo.jp/softwaredeveloper/entry-11967982906.html)
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
