# マウント
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
- マウント済みファイルシステムの情報を取得して`statvfs`構造体に格納する
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

## 参照
- Linuxプログラミングインターフェース 14章 / 15章 / 16章 / 17章 / 18章
