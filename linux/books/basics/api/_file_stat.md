# ファイルの属性
### `stat(2)` / `lstat(2)` / `fstat(2)`
- 指定したファイルのi-nodeを取得し、`stat`構造体に格納する
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
- i-node内に格納される最終アクセス時刻・最終変更時刻を変更する
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

## 参照
- Linuxプログラミングインターフェース 14章 / 15章 / 16章 / 17章 / 18章
