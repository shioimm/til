# グループファイルの参照
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

### `getgrent(3)` / `setgrent(3)` / `endgrent(3)`
- グループファイルをシーケンシャルにスキャンする
- `getgrent(3)` - グループファイル内の情報を一つずつ返す
  - グループファイルをオープンし、スキャンする
- `endgrent(3)` - `getgrent(3)`でオープンしたグループファイルをクローズする

### 返り値
- `getgrent(3)` - `group`構造体を指すポインタを返す
  - 終端に達した場合とエラー時はNULLを返す

## 参照
- Linuxプログラミングインターフェース 2章 / 8章
