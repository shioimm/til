# `/proc`ファイルシステム
- 参照: [procfs](https://ja.wikipedia.org/wiki/Procfs)
- 参照: Webで使えるmrubyシステムプログラミング入門 Section013
- 参照: Linuxプログラミングインターフェース 11章

## TL;DR
- Process Filesystem
- プロセスに関するカーネル内の情報をファイルやディレクトリとして公開する擬似ファイルシステム

### 擬似ファイルシステム
- ディレクトリやファイルはディスク上に存在せず、
  プロセスが`/proc`ディレクトリにアクセスするたびに
  カーネルがその場で作成する

### `/proc`ディレクトリ
- Process Filesystemは`/proc`ディレクトリの下にマウントされ、
  カーネル内部情報をテキストファイルとしてユーザーに提供する
- `/proc`ディレクトリ以下の一部のファイルは読み取り専用
- `/proc`ディレクトリ以下の一部のファイルの操作には権限が必要
- `/proc`ディレクトリ以下のほとんどのファイルのオーナーは`root`

### プロセスの情報
- 各プロセスの情報は`/proc/PID`ディレクトリに格納される
  - 各プロセスの情報は通常カーネル内部で`task_struct`構造体に格納され、
    ユーザーランドからはアクセスできない
  - 各プロセスの情報を必要とする各システムコールは、
    `/proc`ファイルシステムを介することによって
    ユーザーランドから安全にアクセスすることができる
- 各プロセスの情報を格納する`/proc/PID`ディレクトリはプロセス作成時に生成され、終了時に削除される

## 構造
- `/proc/PID/cmdline` - `\0`区切りのコマンドラインパラメータ
- `/proc/PID/comm` - プロセスに紐づけられたプログラム名
- `/proc/PID/cwd` - プロセスのカレントディレクトリへのシンボリックリンク
- `/proc/PID/environ` - プロセスの設定している環境(`\0`区切りの`NAME=value`)
- `/proc/PID/exe` - 実行ファイルへのシンボリックリンク
- `/proc/PID/fd` - プロセスがオープンしているファイルへのシンボリックリンクを持つディレクトリ
- `/proc/PID/fdinfo` - 開いているファイルディスクリプタの状態
  - `pos`フィールド - カレントファイルオフセット
  - `flags`フィールド - ファイルアクセスモード・オープンファイルステータスフラグ(8進数)
- `/proc/loadavg` - システム全体の負荷
  - = 単位時間あたりの実行中プロセス数またはディスクI/O待ちのプロセス数
  - 左から過去1分間の負荷、過去5分間の負荷、過去15分間の負荷
- `/proc/PID/mem` - 仮想メモリ
- `/proc/PID/mouts` - マウントテーブル
- `/proc/PID/root` - ルートディレクトリへのシンボリックリンク
- `/proc/PID/stat` - プロセスに関する様々な情報
  - プログラムに読み取らせるための値の形式で格納されている
- `/proc/PID/status` - プロセスに関する様々な情報
  - umask値 / プロセスのステート / PID・PPID / UID・GID
    / 仮想メモリ / 実メモリ / スワップ利用状況 / 生成されているスレッド数etc
- `/proc/PID/task` - スレッドごとのサブディレクトリを持つディレクトリ
  - `/proc/PID/task/TID` - スレッドID`TID`ディレクトリ
    - `/proc/PID/task/TID`以下の構成は`/proc/PID`以下の構成と同じ

### `/proc`以下の構造
- `/proc` - 各種システム情報
- `/proc/network` - ネットワーク、ソケット
- `/proc/sys/fs` - ファイルシステム
- `/proc/sys/kernel` - カーネルの各種設定、情報
- `/proc/sys/net` - ネットワーク、ソケット
- `/proc/sys/vm` - メモリ管理
- `/proc/sysvipc` - System VIPCオブジェクト

## API
### `uname(2)`
- システムに関する各種情報を取得する
- 情報は`/proc`以下のファイルから取得される

#### 引数
- `*utsbuf`を指定する
  - `*utsbuf` - システムに関する情報を格納する`utsname`構造体へのポインタ

```c
#include <sys/utsname.h>

#define _UTSNAME_LENGTH 65

struct utsname {
  char sysname[_UTSNAME_LENGTH];    // UNIXシステム名
  char nodename[_UTSNAME_LENGTH];   // ネットワークノード名 事前にsethostname(2)で設定したもの
  char release[_UTSNAME_LENGTH];    // OSのリリース番号
  char version[_UTSNAME_LENGTH];    // OSのバージョン番号
  char machine[_UTSNAME_LENGTH];    // ハードウェア識別子
  char domainname[_UTSNAME_LENGTH]; // NISドメイン名 事前にsetdomainname(2)で設定したもの
};
```
- `NIS` - Network Information Services

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す
