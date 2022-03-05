# パスワードファイル
- `/etc/passwd` - ユーザーデータベース
  - `root`ユーザーのエントリーを含む
  - `nobody`ユーザーのエントリーを含む
  - 暗号化されたパスワードは別のファイルに保存する(シャドーパスワードファイル)
  - ユーザーにパスワードが存在しない場合がある
  - 各ユーザーのログインシェルを示すためのフィールドを持つ

```
account:password:UID:GID:GECOS:directory:shell

* account - システム上のユーザー名
* password - x (以前は暗号化されたパスワードが入っていたが現在は/etc/shadowで保存)
* UID - ユーザーID番号
* GID - ユーザーが属するプライマリグループID
* GECOS - ユーザー名またはコメントのフィールド
* directory - ユーザーの$HOMEディレクトリ
* shell - ログイン時に起動されるユーザのコマンドインタプリタ
```

- `<pwd.h>`で定義されるpasswd構造体に格納される

```c
struct passwd {
  char  *pw_name  // ユーザー名
  uid_t pw_uid    // ユーザーID番号
  gid_t pw_gid    // グループID番号
  char  *pw_dir   // 初期ワーキングディレクトリ
  char  *pw_shell // 初期シェル
};
```

## API
- `getpwuid(3)` / `getpwnam(3)`
  - 与えられたログイン名、ユーザ uid、またはユーザ uuid のためにパスワードデータベースを検索
  - `getpwuid(3)` - i-node内のユーザーID番号をユーザーのログイン名に対応づけるため`ls(1)`が使用
  - `getpwnam(3)` - ユーザーがログイン名を打ち込んだ際に`login(1)`が使用
