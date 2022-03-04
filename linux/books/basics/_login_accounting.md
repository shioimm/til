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

### `/var/run/lastlog`ファイル(`_PATH_LASTLOG`)
- ユーザーがシステムへログインした時刻を記録する

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

## `lastlog`構造体
```c
#define UT_NAMESIZE  32
#define UT_HOSTSIZE 256

struct lastlog {
  int32_t ll_time;              // 最終ログイン時刻
  char    ll_line[UT_LINESIZE]; // 端末デバイス名(リモートログイン時)
  char    ll_host[UT_HOSTSIZE]; // ホスト名(リモートログイン時)
};
```

## API
### `setutxent(3)`
- 現在位置を`utmp`ファイルの先頭まで移動する

### `endutxent(3)`
- `utmp`ファイルをクローズする

### `*getutxent(3)` / `*getutxid(3)` / `*gettutxline(3)`
- `utmp`ファイルからレコードを読み取り、`utmpx`構造体へのポインタを返す
- 一致するレコードがない場合、ファイルがEOFに達した場合はNULLを返す
- `wtmp`ファイルを操作する場合は`utmpxname(3)`でパス名を指定する

### `*getlogin(3)`
- 制御端末へログイン中のユーザー名を示す文字列へのポインタを返す
- エラー時はNULLを返す

### `*pututxline(3)`
- 指定した`utmpx`構造体を`/var/run/utmp`ファイルへ記録する

### `updwtmpx(3)`
- 指定した`utmpx`構造体を指定のファイル(`wtmp`ファイル)へ記録する
