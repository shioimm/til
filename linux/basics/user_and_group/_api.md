# API
- 参照: Linuxプログラミングインターフェース 2章 / 8章

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

## グループファイルの参照
### `getgrnam(3)` / `getgrgid(3)`
- グループファイル内の情報を参照する

#### 引数
- `getgrnam(3)` - `*name`を指定する
  - `*name` - グループ名
- `getgrgid(3)` - `gid`を指定する
  - `gid` - GID

#### 返り値
- `group`構造体のポインタを返す
  - エラー時はNULLを返す

```c
#include <grp.h>

struct group {
  char   *gr_name;   // グループ名
  char   *gr_passwd; // 暗号パスワード
  gid_t   gr_gid;    // GID
  char  **gr_mem;    // グループの各ユーザー名へのポインタの配列
};
```
