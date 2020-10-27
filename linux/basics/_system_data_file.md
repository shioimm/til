# システムデータファイル
- 参照: 詳解UNIXプログラミング第3版 6. システムデータファイルと情報

## TL;DR
### 主な種別
- パスワード - `/etc/passwd`
  - `<pwd.h>`で定義される`passwd`構造体に格納される
- シャドー - `/etc/shadow`
  - `<shadow.h>`で定義される`spwd`構造体に格納される
- グループ - `/etc/group`
  - `<grp.h>`で定義される`group`構造体に格納される
- ホスト - `/etc/hosts`
  - `<netdb.h>`で定義される`hostent`構造体に格納される
- ネットワーク - `/etc/networks`
  - `<netdb.h>`で定義される`netent`構造体に格納される
- プロトコル - `/etc/protocols`
  - `<netdb.h>`で定義される`protoent`構造体に格納される
- サービス - `/etc/services`
  - `<netdb.h>`で定義される`servent`構造体に格納される

### インターフェース
- 関数`get` - ファイルをオープンし、次のレコードを読み取る
  - 通常は構造体へのポインタを返す
  - ファイル末尾においてはnullポインタを返す
- 関数`set` - ファイルをオープンし、ファイルを巻き戻す
- 関数`end` - ファイルをクローズする

## パスワードファイル
- `/etc/passwd` - ユーザーデータベース
  - `root`ユーザーのエントリーを含む
  - `nobody`ユーザーのエントリーを含む
  - 暗号化されたパスワードは別のファイルに保存する(シャドーパスワードファイル)
  - ユーザーにパスワードが存在しない場合がある
  - 各ユーザーのログインシェルを示すためのフィールドを持つ
- `<pwd.h>`で定義される`passwd`構造体に格納される
```c
struct passwd {
  char  *pw_name  // ユーザー名
  uid_t pw_uid    // ユーザーID番号
  gid_t pw_gid    // グループID番号
  char  *pw_dir   // 初期ワーキングディレクトリ
  char  *pw_shell // 初期シェル
};
```
- `getpwuid(3)` / `getpwnam(3)` - 与えられたログイン名、ユーザ uid、またはユーザ uuid のためにパスワードデータベースを検索
  - `getpwuid(3)` - iノード内のユーザーID番号をユーザーのログイン名に対応づけるため`ls(1)`が使用
  - `getpwnam(3)` - ユーザーがログイン名を打ち込んだ際に
  `login(1)`が使用

## シャドーパスワードファイル
- `/etc/shadow` - 暗号化されたパスワードを格納するためのファイル
- シャドーパスワードがあれば通常の`/etc/passwd`は誰でも読み取れる
- `<shadow.h>`で定義される`spwd`構造体に格納される
```c
struct spwd {
  char *sp_namp;  // ユーザーログイン名
  char *sp_pwdp;  // 暗号化されたパスワード
  long sp_lstchg; // 1970年1月1日~パスワード最終変更日まで日数
  int  sp_min;    // パスワードが変更出来るようになるまでの日数
  int  sp_max;    // パスワードの変更が必要になるまでの日数
  int  sp_warn;   // パスワード失効の警告をする日数
  int  sp_inact;  // アカウントが不活性になるまでの日数
  int  sp_expire; // 1970年1月1日~アカウントが使用不能となるまでの日数
  int  sp_flag;   // 予約
}
```

## グループファイル
- グループデータベース
- `<grp.h>`で定義される`group`構造体に格納される
```c
struct group {
  char  *gr_name;   // グループ名
  char  *gr_passwd; // 暗号化されたグループのパスワード
  gid_t gr_gid;     // グループ ID
  char  **gr_mem;   // グループの各ユーザー名へのポインタの配列名
};
```
- `getgrgid(3)` - グループIDの検索
- `getgrnam(3)` - グループ名の検索
- `getgrant(3)` - グループファイル全体の検索

## 補助グループID
- ユーザーはパスワードファイルのエントリのグループIDに対応するグープに所属するだけでなく、
  追加のグループ(補助グループ)に所属できる
  - ファイルアクセス許可は実行グループID - ファイルのグループIDだけでなく
    補助グループID - ファイルのグループIDを比較する
- `getgroups(3)` - 補助グループIDリストを取得
- `setgroups(3)` - 補助グループIDリストを設定
- `initgroups(3)` - 追加のグループアクセスリストの初期化

## ログイン記録
- `utmp`ファイル - 現在ログイン中の全てのユーザーを記録する
- `wtmp`ファイル - 全てのログイン・ログアウトを記録する
- ログイン時、プログラム`login`が`utmp`構造体を埋めて`utmp`ファイル/`wtmp`に書き出す
- ログアウト時、プロセス`init`が`wtmp`ファイルのログアウトエントリの`ut_name`に0を埋め込む
- `who(1)`コマンドは`utmp`ファイルを読み取る
```c
struct utmp {
  char ut_line[UT_LINESIZE]; // tty line
  char ut_name[UT_LINESIZE]; // ログイン名
  long ut_time;              // 起点からの経過秒数
};
```

## システムの識別
- `uname(3)` - ホストとOSに関する情報を`utsname`構造体として返す
```c
struct utsname {
  char sysname[];   // OS名
  char nodename[];  // ノード名
  char release[];   // OSのリリース番号
  char version[];   // OSのバージョン */
  char machine[];   // ハードウェア識別子
};
```
- `gethostname(3)` - TCP/IPネットワーク上のホスト名を返す

## 時間と日付
WIP
