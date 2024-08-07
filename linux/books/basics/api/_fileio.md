# 統一IOインターフェース
- 低水準入出力 - システムコールを直接起動することによって提供される入出力機能
  - 低水準入出力はバッファされない
  - 低水準入出力の統一インターフェースはすべての種類のファイルに対して使用可能
    - `open(2)` / `close(2)`(開け閉め)
    - `read(2)` / `write(2)`(読み書き)
    - `lseek(2)`(カレントファイルオフセットを移動させる操作)

#### ファイルオフセット
- リードライトオフセット、ポインタ、ファイルIOポジション
- `read()`や`write()`の開始地点
  - `read()`や`write()`終了時にカレントファイルオフセットは自動的に増加する
- 先頭からのバイト数で表現される
  - 先頭バイト = ファイルオフセット0

#### ファイルホール
- EOFを超えた位置にファイルオフセットを置き、データを書き込んだ場合
  元々あったデータの終端と新しく書き込んだデータの先端の中間に位置するバイト列
  - 中間のバイト列は'0'(NULL文字)で自動的に埋められる
- ファイルホールはディスク上の領域を消費しない
  - ファイルシステムはファイルホールに対してディスクブロックを割り当てない
  - ファイルサイズが実際のディスク消費量よりも大きくなり得る

#### バイトストリーム
- Unixにおけるファイル
- バイトが一列に並んだもの
  - ファイルオフセット - 各バイトの位置を示す整数
  - カレントファイルオフセット - ファイルの読み書き位置となるファイルオフセット

#### フラグ
- ファイルに対してどのように操作するか、ファイルがどのような状態かを表現したマクロ
  - ファイルアクセスモードフラグ: 読み、書き、その他
  - ファイル作成フラグ: 作成、ファイルサイズの変更、その他
    - オープン後に参照・変更できない
  - オープンファイルステータスフラグ: ノンブロッキングモードでオープン、書き込みを同期IO化、その他
    - オープン後に参照・変更できる

## 統一IOインターフェース
### `open(2)`
- ファイルを開く = そのファイルをこれから使うということをカーネルに知らせる

#### 引数
- `path`、`flags`、`mode`を指定する
  - `flags` - フラグ
  - `mode` - パーミッションビット

#### 返り値
- ファイルディスクリプタを返す
  - `open(2)`を呼んだプロセスが使用可能なもののうち、最小値のもの

### `creat(2)`
- 新規にファイルを作成・オープンする
- `open(2)`の方が柔軟にフラグを指定できるためあまり使われない

#### 引数
- `pathname`、`mode`を指定する
  - `mode` - パーミッションビット

#### 返り値
- ファイルディスクリプタを返す
  - `open(2)`を呼んだプロセスが使用可能なもののうち、最小値のもの

### `close(2)`
- オープン済みのファイルディスクリプタを閉じる
  - プロセスからは以降使用不可となる
  - ファイルに対してプロセスが保持していたリソースが解放される
- オープンしていないファイルディスクリプタをクローズしようとした場合や
  同じファイルディスクリプタを複数回クローズしようとした場合にエラーが発生

#### 引数
- `fd`を指定する

#### 返り値
- `0`を返す

### `read(2)`
- 指定のファイルディスクリプタからファイル内容を読み取る
- ファイルにあるバイト列をプロセスのメモリ領域に読み込む
  - バッファ - プロセスのメモリ領域
    - char型の配列としてプログラム上で用意する
  - EOF - ファイルの終わりの位置
    - 読み込む予定のバイト数よりも実際に読み込んだバイト数の方が少ない = EOF
  - 何も書かれていない部分のバイトは値0のバイトとして返す
- Ex. カレントファイルオフセットから10バイト分のバイト列を読む
  -> バッファに10バイト分のデータが入る
  -> カレントファイルオフセットが10バイト分移動する

#### 引数
- `fd`、`buffer`、`count`を指定する
  - `buffer` - 読み取ったデータを格納するメモリバッファアドレス
  - `count` - 読み取るバイト数

#### 返り値
- 読み取ったバイト数を返す
- どんなデータでも読み取れる
- 要求バイト数より読み取るバイト数が少ない場合がある
  - 要求バイト数分読み取る前にファイル末尾に達した場合
  - 端末から読み取る場合
  - ネットワークから読み取る場合(ネットワークのバッファリング)
  - パイプから読み取る場合
  - シグナルによる割り込みが発生した場合
- 入力データの最後に`NULL`が必要な場合は明示的に`'\0'`を付加する

### `write(2)`
- バッファの内容をファイルに書き込む
  - 元々のデータは上書きされる
- Ex. カレントファイルオフセットから10バイト分のバッファをファイルに書き込む
  -> カレントファイルオフセットが10バイト分移動する(EOF)
- ディスクが満杯であったり、プロセスのファイルサイズの上限を越えるとエラーになる

#### 引数
- `fd`、`buffer`、`count`を指定する
  - `buffer` - 書き込むデータのメモリバッファアドレス
  - `count` - `buffer`内のバイト数

#### 返り値
- 書き込んだバイト数を返す
- 要求バイト数より書き込むバイト数が少ない場合がある
  - ディスクがいっぱいになった場合
  - ファイルサイズの上限に達した場合

### `lseek(2)`
- カレントファイルオフセットを明示的に移動させ、新しいファイルオフセットを返す
  - 0バイト移動によって現在のファイルオフセット値を得られる
  - 通常カレントファイルオフセットは`read(2)` `write(2)`によって読み書きしたデータ分移動する
  - `lseek(2)`では読み書きをせずにカレントファイルオフセットを移動させる
- 新しいファイルオフセットはその次の`read` `write`時に使用される
- 元のファイルサイズよりも大きい値を指定した場合、次の`write`時にファイル容量が拡張される(ファイルに隙間を作る)
- パイプ、FIFO、ソケット、端末に対する操作は無意味なのでエラーとなる(`ESPIPE`)

#### 引数
- `fd`、`offset`、`whence`を指定する
  - `offset` - バイト数
  - `whence` - `offset`バイトをどのように移動させるか

#### 返り値
- 移動後のファイルオフセットの値

```c
// カレントファイルオフセットの取得

off_t curr = lseek(fd, 0, SEEK_CUR);
```

## 統一IOインターフェース以外のシステムコール
### `ioctl(2)`
- 統一IOモデルから外れる多種多様な操作を行うための汎用システムコール
  - 端末操作など

#### 引数
- `fd`、`request`を指定し、残りは`request`に応じた可変長引数
  - `request` - 処理内容を表すマクロ

### `pread(2)` / `pwrite(2)`
- `read(2)` / `write(2)`と同様
- ファイルオフセットを明示的に指定できる
- シーク可能なファイルであること
- ファイルに対する競合が発生するような作業において有効
  - プロセス内の全スレッドはファイルディスクリプタテーブルを共有し、
    カレントファイルオフセットを共有するような場合
  - 複数のプロセスが操作する各自のファイルディスクリプタが
    同じオープンファイルを指している場合
  - `pread(2)` / `pwrite(2)`を使用すれば
    複数のスレッドが同じファイルディスクリプタに対してIOを行なっても
    他のスレッドのファイルオフセットには干渉しない

#### 引数
- `fd`、`buf`、`count`、`offset`を指定する

### `readv(2)` / `writev(2)`
- スキャッターギャザIOを実行する
  - scatter read / gather write - 一度のシステムコールで不連続な複数のバッファを使用する
  - `readv(2)` - ファイルディスクリプタからデータを読み取り、複数のバッファへ分散格納
  - `writev(2)` - 複数のバッファを連結し、一連のデータをファイルディスクリプタへ書き込み
  - アトミックに動作し、全てのデータがIO順に処理されることを保証する
  - `preadv(2)` / `pwritev(2)` - ファイルオフセット可能なスキャッターギャザIO

#### 引数
- `fd`、`*iov`、`iovcnt`を指定する
  - `*iov` - `iovec`構造体の配列へのポインタ
  - `iovcnt` - 配列`*iov`の要素数

```c
struct iovec {
  void   *iov_base; // バッファの開始アドレス
  size_t  iov_len;  // バッファ内のIOするバイトサイズ
};
```

#### 返り値
- `readv(2)` - 読み取ったバイト数
- `writev(2)` - 書き込まれたバイト数

### `truncate(2)` / `ftruncate(2)`
- 既存のファイルを指定のファイルサイズに変更する
  - 指定のファイルサイズが既存のファイルサイズよりも小さき場合
    ファイルサイズが減り、指定サイズ以上のデータは破棄される
  - 指定のファイルサイズが既存のファイルサイズよりも大きい場合
    ファイルサイズが増え、データが存在しない部分はファイルホールとなる(0埋めされる)

#### 引数
- `truncate(2)` - `*pathname`、`length`を指定する
- `ftruncate(2)` - `fd`、`length`を指定する

### `mktemp(3)`
- 与えられたテンプレートから一意なファイル名を作成し、ファイルをオープンする
- オーナーのみが読み書き可能なパーミッションでファイルを作成する

#### 引数
- `*templete`を指定する
  - `*templete` - 生成するパスの基礎となる文字列
    - `XXXXXX`を含んでいる必要がある(`XXXXXX`が適当な文字列に置き換わる)

#### 返り値
- 作成したファイルディスクリプタ
- クローズ時に自動で破棄されるように内部で`unlink()`が呼ばれる

### `tempfile(3)`
- 一意な名前のテンポラリファイルを生成し、読み書き両用にオープンする

#### 返り値
- ファイルストリーム(`FILE`)

## 参照
- 例解UNIX/Linuxプログラミング教室P107-148 / P271-275
- 詳解UNIXプログラミング第3版 3. ファイル入出力
- 詳解UNIXプログラミング第3版 4. ファイルとディレクトリ
- Linuxプログラミングインターフェース 4章 / 5章 / 13章
