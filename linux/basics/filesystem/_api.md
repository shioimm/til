# API
- 参照: Linuxプログラミングインターフェース 14章 / 15章

## マウント
### `mount(8)`
- `device`に存在するファイルシステムをディレクトリ階層内`directory`の位置へマウントする
```
$ mount device directory
```

#### tmpfsの作成
```
$ mount -t tmpfs newtmp /tmp
```
- `newtmp` - マウント時の表示上の名前
- `/tmp` - マウントポイント

### `mount(2)`
- 指定されたデバイス上に存在するファイルシステムを指定のディレクトリへマウントする

#### 引数
- `*source`、`*target`、`*fstype`、`mountflags`、`*data`を指定する
  - `*source` - 指定するデバイスを表す文字列へのポインタ
  - `*target` - 指定するディレクトリ(マウントポイント)を表す文字列へのポインタ
  - `*fstype` - ファイルシステム種類を表す文字列へのポインタ
  - `mountflags` - マウント処理を制御するオプションフラグ
  - `*data` - ファイルシステムが要求する専用データへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `unmount(8)`
- マウントされたファイルシステムをディレクトリ以下から外す

### `unmount(2)` / `unmount2(2)`
- マウント済みファイルシステムをアンマウントする
- `unmount2(2)` - アンマウント処理を制御するオプションフラグを渡すことができる

#### 引数
- `unmount(2)` - `*target`を指定する
  - `*target` - ファイルシステムのマウントポイントを表す文字列へのポインタ
- `unmount2(2)` - `*target`、`flags`を指定する
  - `*target` - ファイルシステムのマウントポイントを表す文字列へのポインタ
  - `flags` - アンマウント処理を制御するオプションフラグ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## ファイルシステム情報
### `statvfs(3)` / `fstatvfs(3)`
- マウント済みファイルシステムの情報を取得して`statvfs`構造体に保存する
```c
struct statvfs {
  unsigned long  f_bsize;   // ブロックサイズ
  unsigned long  f_frsize;  // フラグメントサイズ
  fsblkcnt_t     f_blocks;  // ブロック数
  fsblkcnt_t     f_bfree;   // 解放されているブロック数
  fsblkcnt_t     f_bafvail; // 非特権プロセスが使用可能な解放されているブロック数
  fsfilcnt_t     f_files;   // i-node数
  fsfilcnt_t     f_ffree;   // 解放されているi-nodeの数
  fsfilcnt_t     f_favail;  // 非特権プロセスが使用可能な解放されているi-node数
  unsigned long  f_fsid;    // ファイルシステムID
  unsigned long  f_flag;    // マウントフラグ
  unsigned long  f_namemax; // 最長ファイル名
};
```

#### 引数
- `statvfs(3)` - `*pathname`、`*statvfsbuf`を指定する
  - `*pathname` - 対象ファイルシステム内の任意のファイルのパス名を表す文字列へのポインタ
  - `*statvfsbuf` - ファイルシステム情報を格納する`statvfs`構造体へのポインタ
- `fstatvfs(3)` - `fd`、`*statvfsbuf`を指定する
  - `fd` - 対象ファイルシステム内の任意のファイルをオープンしたファイルディスクリプタ
  - `*statvfsbuf` - ファイルシステム情報を格納する`statvfs`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## ファイルの属性
### `stat(2)` / `lstat(2)` / `fstat(2)`
- 指定したファイルのi-nodeを取得し、`stat`構造体に保存する
- `stat(2)` - パス名により指定する
- `lstat(2)` - 対象ファイルがシンボリックリンクの場合、シンボリックリンク自身の情報を取得する
- `fstat(2)` - ファイルディスクリプタにより指定する

```c
#include <sys/stat.h>

struct stat {
  dev_t     st_dev;     // ファイルが存在するデバイスID
  ino_t     st_ino;     // i-node番号
  mode_t    st_mode;    // ファイルの種類とパーミッション
  nlink_t   st_nlink;   // ハードリンクカウント
  uid_t     st_uid;     // ファイルを所有するオーナーのUID
  gid_t     st_gid;     // ファイルを所有するオーナーのGID
  dev_t     st_rdev;    // (ファイルがデバイスファイルの場合)デバイスファイルに対応するデバイスID
  off_t     st_size;    // ファイルのバイトサイズ
  blksize_t st_blksize; // このファイルシステムへのIOに最適なブロックサイズ
  blkcnt_t  st_blocks;  // 消費ブロック数(512バイト長ブロック単位の個数)
  time_t    st_atim;    // 最終アクセス時刻
  time_t    st_mtim;    // 最終変更時刻
  time_t    st_ctim;    // 最終i-node変更時刻
};
```

#### `dev_t`型
- メジャー番号・マイナー番号を表す型
- `major()` / `minor()`マクロを用いてメジャー番号・マイナー番号を取り出す

#### `mode_t st_mode`
- ファイル種類(4ビット)
  - `S_ISREG` - ファイル
  - `S_ISRDIR` - ディレクトリ
  - `S_ISCHR` - 文字型特殊ファイル(端末など)
  - `S_ISBLK` - ブロック型特殊ファイル(ディスクなど)
  - `S_ISLNK` - シンボリックリンク
  - `S_ISFIFO` - FIFO(名前付きパイプ)
  - `S_ISSOCK` - ソケット
- パーミッション(12ビット)
  - アクセス許可ビット(9ビット)
  - set-user-IDビット(1ビット)
  - set-group-IDビット(1ビット)
  - スティッキービット(1ビット)

#### 引数
- `stat(2)` / `lstat(2)` - `*pathname`、`*statbuf`を指定する
  - `*pathname` - 対象ファイルシステム内の任意のファイルのパス名を表す文字列へのポインタ
  - `*statbuf` - ファイル情報を格納する`stat`構造体へのポインタ
- `fstat(2)` - `fd`、`*statbuf`を指定する
  - `fd` - 対象ファイルのファイルディスクリプタ
  - `*statbuf` - ファイル情報を格納する`stat`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `utime(2)` / `utimes(2)`
- i-node内に保存される最終アクセス時刻・最終変更時刻を変更する
- `utime(2)` - `utimbuf`構造体によって変更する

```c
struct utimbuf {
  time_t actime;  // アクセス時刻
  time_t modtime; // 変更時刻
};
```

- `utimes(2)` - `timeval`構造体によって変更する
- `utimesat(2)` - `timespec`構造体によって変更する
- `futimens(3)` - `timespec`構造体によって変更する・ファイルディスクリプタを使用できる

#### 引数
- `utime(2)` - `*pathname`、`*buf`を指定する
  - `*pathname` - 指定のファイルのパス名を表す文字列へのポインタ
  - `*buf` - 時刻情報を格納する`utimbuf`構造体へのポインタ
    - NULLを指定するとアクセス時刻・更新時刻を現在時刻へ変更する
    - 値を詰めた`utimbuf`構造体へのポインタを指定するとその値へ変更される
- `utimes(2)` - `*pathname`、`tv[2]`を指定する
  - `*pathname` - 指定のファイルのパス名を表す文字列へのポインタ
  - `tv[0]` - 最終アクセス時刻を格納する`timeval`構造体へのポインタ
  - `tv[1]` - 最終変更時刻を格納する`timeval`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## ファイルオーナー
### `chown(2)` / `fchown(2)` / `lchown(2)`
- 指定のファイルのオーナー・グループを変更する
- `chown(2)` - パス名によって位指定する
- `lchown(2)` - 対象ファイルがシンボリックリンクの場合、シンボリックリンク自身のオーナー・グループを変更する
- `lchown(2)` - ファイルディスクリプタにより指定する

#### 引数
- `chown(2)` / `lchown(2)` - `*pathname`、`owner`、`group`を指定する
  - `*pathname` - 対象ファイルシステム内の任意のファイルのパス名を表す文字列へのポインタ
  - `owner` - UID
  - `group` - GID
- `fchown(2)` - `fd`、`owner`、`group`を指定する
  - `fd` - 対象ファイルのファイルディスクリプタ
  - `owner` - UID
  - `group` - GID

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す
