# procfs
- システムに存在するプロセスについての情報をファイルやディレクトリとして公開する仮想ファイルシステム
  - `/proc`ディレクトリ以下にマウントされる
  - 各プロセスの情報は`/proc/PID`ディレクトリに格納される
  - `/proc/PID`ディレクトリはプロセス作成時に生成され、終了時に削除される
  - ディレクトリやファイルはディスク上に存在せず、
    プロセスが`/proc`ディレクトリにアクセスするたびにカーネルがその場で作成する

## `proc/<PID>/`以下の構造

| 項目                   | 説明                                                                            |
| -                      | -                                                                               |
| `/proc/<PID>/cmdline`  | プロセスのコマンドライン引数                                                    |
| `/proc/<PID>/comm`     | プロセスに紐づけられたプログラム名                                              |
| `/proc/<PID>/cwd`      | プロセスのカレントディレクトリへのシンボリックリンク                            |
| `/proc/<PID>/environ`  | プロセスの設定している環境(`\0`区切りの`NAME=value`)                            |
| `/proc/<PID>/exe`      | 実行ファイルへのシンボリックリンク                                              |
| `/proc/<PID>/fd`       | プロセスがオープンしているファイルへのシンボリックリンクを持つディレクトリ      |
| `/proc/<PID>/fdinfo`   | 開いているファイルディスクリプタの状態                                          |
| `/proc/<PID>/loadavg`  | システム全体の負荷 (時間あたり実行中プロセス数またはディスクI/O待ちのプロセス数 |
| `/proc/<PID>/mem`      | 仮想メモリ                                                                      |
| `/proc/<PID>/mouts`    | マウントテーブル                                                                |
| `/proc/<PID>/root`     | ルートディレクトリへのシンボリックリンク                                        |
| `/proc/<PID>/stat`     | プロセスの状態、これまでに使用したCPU時間、優先度、使用メモリ量など             |
| `/proc/<PID>/status`   | プロセスに関する様々な情報                                                      |
| `/proc/<PID>/task`     | スレッドごとのサブディレクトリを持つディレクトリ                                |
| `/proc/<PID>/task/TID` | スレッドID`TID`ディレクトリ                                                     |

## `/proc`以下の構造

| 項目               | 説明                                             |
| -                  | -                                                |
| `/proc`            | 各種システム情報                                 |
| `/proc/cpuinfo`    | システムが搭載するCPUに関する情報                |
| `/proc/diskstat`   | システムが搭載するストレージデバイスに関する情報 |
| `/proc/meminfo`    | システムが搭載するメモリに関する情報             |
| `/proc/network`    | ネットワーク、ソケット                           |
| `/proc/sys`        | カーネルの各種チューニングパラメータ             |
| `/proc/sys/fs`     | ファイルシステム                                 |
| `/proc/sys/kernel` | カーネルの各種設定、情報                         |
| `/proc/sys/net`    | ネットワーク、ソケット                           |
| `/proc/sys/vm`     | メモリ管理                                       |
| `/proc/sysvipc`    | System VIPCオブジェクト                          |

## 参照
- [procfs](https://ja.wikipedia.org/wiki/Procfs)
- Webで使えるmrubyシステムプログラミング入門 Section013
- Linuxプログラミングインターフェース 11章
