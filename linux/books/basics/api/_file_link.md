# リンク
### `link(2)`
- ハードリンクを作成する

#### 引数
- `*oldpath`、`*newpath`を指定する
  - `*oldpath` - 既存のファイル名を表す文字列へのポインタ
  - `*newpath` - `*oldpath`を参照するハードリンクを表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `unlink(2)`
- ハードリンクを削除する
- 削除したリンクがファイルの最後のリンクだった場合はファイル自身を削除する

#### 引数
- `*pathname`を指定する
  - `*pathname` - 削除するハードリンクを表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `rename(2)`
- ディレクトリエントリを操作して
  - ファイル名を変更する
  - 同一ファイルシステム内の他のディレクトリ以下へファイルを移動する

#### 引数
- `*oldpath`、`*newpath`を指定する
  - `*oldpath` - 既存のパス名を表す文字列へのポインタ
  - `*newpath` - 変更後の新パス名を表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `symlink(2)`
- シンボリックリンクを作成する
- 削除の際は`unlink(2)`を使用する

#### 引数
- `*filepath`、`*linkpath`を指定する
  - `*filepath` - リンク先のファイル名を表す文字列へのポインタ
    - ファイル名が存在していなくても良い
  - `*linkpath` - `*filepath`を参照するシンボリックリンクを表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `readlink(2)`
- シンボリックリンクの参照先パス名を取得する

#### 引数
- `*pathname`、`*buffer`、`bufsiz`を指定する
  - `*pathname` - シンボリックリンクを表す文字列へのポインタ
  - `*buffer` - シンボリックリンクの参照先パス名を格納するバッファへのポインタ
  - `bufsiz` - `*buffer`が指す領域のサイズ

#### 返り値
- `*buffer`へコピーしたバイト数を返す
  - エラー時は数値-1を返す

### `mkdir(2)`
- 空のディレクトリを作成する
- 新規に作成したディレクトリはリンク`.` / `..`を自動生成する

#### 引数
- `*pathname`、`mode`を指定する
  - `*pathname` - 作成するディレクトリ名を表す文字列へのポインタ
  - `mode` - 作成するディレクトリへのパーミッション

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `rmdir(2)`
- 空のディレクトリを削除する

#### 引数
- `*pathname`を指定する
  - `*pathname` - 削除するディレクトリ名を表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `remove(2)`
- ファイル、空のディレクトリを削除する
- 引数`*pathname`はファイル名の場合は内部で`unlink(2)`を実行する
- 引数`*pathname`がディレクトリの場合は内部で`rmdir(2)`を実行する

#### 引数
- `*pathname`を指定する
  - `*pathname` - 削除するファイル・ディレクトリ名を表す文字列へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `opendir(3)` / `fdopendir(3)`
- ディレクトリをオープンし、ディレクトリストリームハンドル(`DIR`型)を返す
  - `DIR`構造体 - ディレクトリストリーム / 読み取り中のディレクトリに関する情報を管理する内部構造

#### 引数
- `opendir(3)` - `*dirpath`を指定する
- `fdopendir(3)` - `fd`を指定する

#### 返り値
- ディレクトリストリームハンドル(`DIR`型)へのポインタを返す
  - エラー時は数値-1を返す

### `readdir(3)`
- 指定されたディレクトリストリーム(`DIR`型)内のエントリを見つかった順に一つずつ読み取る
- 内部でスタティックに割り当てた`dirent`構造体へのポインタを返す
  - `readdir(3)`を実行するたびに中身が上書きされる

```c
// dirent構造体 - ディレクトリエントリの情報を格納する構造体

struct dirent {
  ino_t d_ino;       // ファイルのi-node番号
  char  d_name[256]; // NULL終端のファイル名
};
```

- `scandir(3)` - ファイル名をソートする場合
- `r_readdir(3)` - `readdir(3)`をリエントラントに実行する場合
- `rewinddir(3)` - ディレクトリストリームのファイルオフセットを先頭に移動する

#### 引数
- `*dirp`を指定する
  - `*dirp` - 指定のディレクトリストリームへのポインタ

#### 返り値
- 次のディレクトリエントリへのポインタを返す
  - 次のエントリがない場合は時はNULLを返す
  - エラー時はNULLを返す

### `closedir(3)`
- 指定のディレクトリストリームをクローズし、リソースを解放する

#### 引数
- `*dirp`を指定する
  - `*dirp` - 指定のディレクトリストリームへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `dirfd(3)`
- 指定のディレクトリストリームが内部に持つファイルディスクリプタを取得する

#### 引数
- `*dirp`を指定する
  - `*dirp` - 指定のディレクトリストリームへのポインタ

#### 返り値
- ファイルディスクリプタを返す
  - エラー時は数値-1を返す

### `nftw(3)`
- 指定されたディレクトリ以下を再帰的に辿り、
  発見された全てのファイルに対して指定の処理を実行する

#### 引数
- `*dirpath`、`*func`、`nopenfd`、`flags`を指定する
  - `*dirpath` - 指定のディレクトリへのパスを表す文字列へのポインタ
  - `*func` - 実行する処理(関数)を表す数値へのポインタ
    - `*pathname` - ファイル名を表す文字列へのポインタ
    - `*statbuf` - `stat`構造体へのポインタ
    - `typeflag` - ファイルの詳細を表す情報
    - `*ftwbuf` - `FTW`構造体へのポインタ
  - `nopenfd` - 使用するファイルディスクリプタ数(ツリーレベルにつき一つ)の上限
  - `flags` - 指定の処理を実行する際のフラグ

```c
// FTW構造体

struct FTW {
  int base;  // パス名中の末端ファイル名までのオフセット
  int level; // 処理対象ツリー内での深さ
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `getcwd(3)`
- カレントワーキングディレクトリ(絶対パス)を取得する

#### 引数
- `*cwdbuf`、`size`を指定する
  - `*cwdbuf` - カレントワーキングディレクトリを表す文字列を格納するバッファへのポインタ
  - `size` - パス名長の上限

#### 返り値
- `cwdbuf`を返す
  - エラー時はNULLを返す

### `chdir(2)` / `fchdir(2)`
- 自プロセスのカレントワーキングディレクトリを指定のディレクトリへ変更する
- `chdir(2)` / `fchdir(2)`を実行するプロセスと、
  実行するプロセスを起動したプロセスは別のプロセスであるため
  後者のカレントワーキングディレクトリには影響を及びさない

#### 引数
- `chdir(2)` - `*pathname`を指定する
- `fchdir(2)` - `fd`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `chroot(2)`
- 自プロセスのルートディレクトリを指定のディレクトリへ変更する
- 特権を持つプロセスに限る

#### 引数
- `*pathname`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `realpath(3)`
- 指定のパス名を絶対パスとして解決する

#### 引数
- `*pathname`、`*resolved_path`を指定する
  - `*resolved_path` - 解決したパス名を格納する文字列へのポインタ

#### 返り値
- 解決した文字列へのポインタを返す
  - エラー時はNULLを返す

### `dirname(3)` / `basename(3)`
- `dirname(3)` - 指定のパス名からディレクトリ名を取得する
- `basename(3)` - 指定のパス名から末端ファイル名を取得する

#### 引数
- `*pathname`を指定する

#### 返り値
- NULLで終端する文字列へのポインタを返す

## 参照
- Linuxプログラミングインターフェース 14章 / 15章 / 16章 / 17章 / 18章