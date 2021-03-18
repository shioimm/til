# ログインアカウンティング
- 参照: Linuxプログラミングインターフェース 40章

## TL;DR
- システムにログイン中のユーザー、ログイン・ログアウトの履歴を記録する機能

###`/var/run/utmp`ファイル(`_PATH_UTMP`)
- 現在ログイン中のユーザー情報を保持するファイル
  - ユーザーがログインするたびにログイン名などが毎回記録され、ログアウト時に削除される

### `/var/run/wtmp`ファイル(`_PATH_WTMP`)
- ユーザーのログイン・ログアウトの履歴を保持する
  - ログインのたびに`utmp`ファイルと同じ情報が追加され、ログアウト時にも追加される

## `utmpx`構造体
- `utmp` / `wtmp`ファイルでは`utmpx`構造体を一レコードとしてレコードが連続した構造を取る
```c
#define _GNU_SOURCE

#define UT_LINESIZE  32
#define UT_NAMESIZE  32
#define UT_HOSTSIZE 256

struct exit_status {
  short int e_termination; // プロセス終了ステータス
  short int e_exit;        // プロセス終了コード
};

struct utmp {
  short   ut_type;              // レコード種類
  pid_t   ut_pid;               // ログインプロセスのPID
  char    ut_line[UT_LINESIZE]; // 端末デバイス名
  char    ut_id[4];             // 端末デバイス名のsuffix
  char    ut_user[UT_NAMESIZE]; // ユーザー名
  char    ut_host[UT_HOSTSIZE]; // ホスト名(リモートログイン時) or カーネルバージョン
  struct  exit_status ut_exit;  // DEAD_PROCESSの終了コード
  long    ut_session;           // セッションID
  struct  timeval ut_tv;        // 記録時刻
  int32_t ut_addr_v6[4];        // リモートホストのIPアドレス
  char    __unused[20];         // 予約
};
```
