# ユーザー管理
## 自プロセスの実IDの操作
### `getuid(2)` / `getgid(2)`
- 実ユーザーID / 実グループIDの取得

## 自プロセスの実効IDの操作
### `geteuid(2)` / `getegid(2)`
- 実効ユーザーID / 実効グループIDの取得

### `setuid(2)` / `setgid(2)`
- 実効ユーザーID / 実効グループIDの変更
  - 非特権プロセスの場合、
    実効IDを現在の実IDかsaved set-IDと値へ変更できる
  - 特権プロセスの場合、
    実ID / 実効ID / saved set-IDを指定の同一の値へ変更できる

#### 引数
- `setuid(2)` - `uid`を指定する
- `setgid(2)` - `gid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `seteuid(2)` / `setegid(2)`
- 実効ユーザーID / 実効グループIDの変更
  - 非特権プロセスの場合、
    実効IDを現在の実IDかsaved set-IDと値へ変更できる
  - 特権プロセスの場合、
    実効IDを指定の値へ変更できる

#### 引数
- `seteuid(2)` - `euid`を指定する
- `setegid(2)` - `egid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## 自プロセスの実ID / 実効IDの操作
### `setreuid(2)` / `setregid(2)`
- 実ユーザーID・実効ユーザーID / 実グループID・実効グループIDの変更
  - 非特権プロセスの場合、
    実IDを現在の実IDか実効ID、
    実効IDを現在の実IDか実効IDかsaved set-IDへ変更できる
  - 特権プロセスの場合、
    実ID・実効IDを指定の値に変更できる

#### 引数
- `setreuid(2)` - `ruid`、`euid`を指定する
- `setregid(2)` - `rgid`、`egid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## 自プロセスの実ID / 実効ID / saved set-IDの操作
### `getresuid(2)` / `getresgid(2)`
- 実ユーザーID・実効ユーザーID・saved set-user-ID / 実グループID・実効グループID・saved set-group-IDの取得

#### 引数
- `setresuid(2)` - `*ruid`、`*euid`、`*suid`を指定する
- `setresgid(2)` - `*rgid`、`*egid`、`*sgid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `setresuid(2)` / `setresgid(2)`
- 実ユーザーID・実効ユーザーID・saved set-user-ID / 実グループID・実効グループID・saved set-group-IDの変更
  - 非特権プロセスの場合、実ID・実効ID・saved set-IDを現在の実IDか実効IDかsaved set-IDへ変更できる
  - 特権プロセスの場合、実ID・実効ID・saved set-IDを指定の値に変更することができる

#### 引数
- `setreuid(2)` - `ruid`、`euid`、`suid`を指定する
- `setregid(2)` - `rgid`、`egid`、`sgid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## 参照
- linuxプログラミングインターフェース 2章 / 8章
