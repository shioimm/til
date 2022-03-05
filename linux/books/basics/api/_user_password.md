# パスワードの管理
## パスワードファイルの参照
### `getpwnam(3)` / `getpwuid(3)`
- パスワードファイル内の情報を参照する

#### 引数
- `getpwnam(3)` - `*name`を指定する
  - `*name` - ログイン名
- `getpwuid(3)` - `uid`を指定する
  - `uid` - UID

#### 返り値
- `passwd`構造体のポインタを返す
  - エラー時はNULLを返す

```c
#include <pwd.h>

struct passwd {
  char  *pw_name;   // ログイン名
  char  *pw_passwd; // 暗号パスワード
  uid_t  pw_uid;    // UID
  gid_t  pw_gid;    // GID
  char  *pw_gecos;  // コメント
  char  *pw_dir;    // ホームディレクトリ
  char  *pw_shell;  // ログインシェル
};
```

### `getpwent(3)` / `setpwent(3)` / `endpwent(3)`
- パスワードファイルをシーケンシャルにスキャンする
- `getpwent(3)` - パスワードファイル内の情報を一つずつ返す
  - パスワードファイルをオープンし、スキャンする
- `endpwent(3)` - `getpwent(3)`でオープンしたパスワードファイルをクローズする

### 返り値
- `getpwent(3)` - `passwd`構造体を指すポインタを返す
  - 終端に達した場合とエラー時はNULLを返す

## shadowパスワードファイルの参照
### `getspnam(3)`
- shadowパスワードファイル内の情報を参照する

#### 引数
- `getspnam(3)` - `*name`を指定する
  - `*name` - ログイン名

#### 返り値
- `spwd`構造体を指すポインタを返す
  - エラー時はNULLを返す

```c
#include <shadow.h>

struct spwd {
  char *sp_namp;  // ログイン名
  char *sp_pwdp;  // 暗号パスワード
  long sp_lstchg; // パスワード変更日
  int  sp_min;    // パスワード変更可能間隔
  int  sp_max;    // パスワード無変更可能間隔
  int  sp_warn;   // パスワード期限切れ警告猶予期間
  int  sp_inact;  // パスワード期限切れんの場合、アカウントロック猶予期間
  int  sp_expire; // パスワード期限切れんの場合、アカウントロック日
  int  sp_flag;   // 予約領域
};
```

### `getspent(3)` / `setspent(3)` / `endspent(3)`
- shadowパスワードファイルをシーケンシャルにスキャンする
- `getspent(3)` - shadowパスワードファイル内の情報を一つずつ返す
  - shadowパスワードファイルをオープンし、スキャンする
- `endspent(3)` - `getspent(3)`でオープンしたshadowパスワードファイルをクローズする

### 返り値
- `getspent(3)` - `spwd`構造体を指すポインタを返す
  - 終端に達した場合とエラー時はNULLを返す

## 参照
- Linuxプログラミングインターフェース 2章 / 8章
