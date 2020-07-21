# procfs
- 参照: [procfs](https://ja.wikipedia.org/wiki/Procfs)

## TL;DR
- Process Filesystem
- プロセスに関するカーネル情報をファイル形式で表示するための擬似ファイルシステム
  - ユーザーランドから安全にプロセスの情報へアクセスするためのもの
- 各プロセスの情報は/proc/PIDディレクトリにマウントされる

## 構造
- /proc/PID/cmdline
  - プロセスを起動したコマンドとその引数の情報
- /proc/PID/comm
  - プロセスに紐づけられたプログラム名
- /proc/PID/exe
  - 元々の実行ファイルへのシンボリックリンク
- /proc/PID/cwd
  - プロセスのカレントディレクトリへのシンボリックリンク
- /proc/PID/environ
  - プロセスの設定している環境変数
- /proc/PID/status
  - プロセスに関する基本情報(動作状態やメモリ使用状況)
- /proc/PID/stat
  - プロセスの状態についての情報
- /proc/PID/fd
  - 開いているファイルディスクリプタに対応したシンボリックリンク群
- /proc/PID/fdinfo
  - 開いているファイルディスクリプタの状態
- /proc/loadavg
  - システム全体の負荷(= 実行待ちまたはディスクI/O待ちのプロセス数)
  - 左から過去1分間の負荷、過去5分間の負荷、過去15分間の負荷
