# ファイルロック
- 参照: Linuxプログラミングインターフェース 55章

## TL;DR
- ファイルIOに対する同期機構(`flock(2)` / `fcntl(2)`)
- カーネルがロックとファイルの対応を自動的に管理する
- デフォルトのロックはアドバイザリロック(強制力がないロック)
  - 各プロセスがIOを実行する前にファイルをロックするよう強調する必要がある

## 使用手順
1. ファイルをロックする
2. ファイルIOを実行する
3. ファイルをアンロックし、他プロセスからロック可能とする

## バッファリング
- `stdio`ライブラリはユーザー空間でバッファリングするため、
  ファイルをロックする前に入力がバッファリングされる
  ファイルをアンロックする前に出力バッファがフラッシュされる
  - ファイルロック直後・ファイルアンロック直前にに明示的に`stdio`ストリームをフラッシュする
  - `stdio`のバッファリングを停止する
  - `stdio`ライブラリを使用せずシステムコールで代用する

## `/proc/locks`
- システム上に存在するロックは`/proc/locks`から確認できる
  - 通し番号
  - ロックを設けたシステムコール
  - ロックモード
  - ロック種類
  - ロックを保持するプロセスID
  - ロック対象のファイルを示すメジャーデバイスID:マイナーデバイスID:i-node番号
  - ロック範囲開始バイト
  - ロック範囲終了バイト

## `flock(2)`
- BSD由来
- 指定のファイル全体をロックする
- 共有ロック・排他ロックはファイルのアクセスモードとは関係しない
- `flock(2)`し直すことによって共有ロック -> 排他ロック / 排他ロック -> 共有ロックへ変換可能
  - ロックの変換中に他のプロセスのロックが割り込む可能性がある
- ロックはアンロックするかファイルディスクリプタをクローズすることで解放される
- 複製されたファイルディスクリプタ(`dup(2)`、`fork(2)`など)も
  元のファイルディスクリプタと同じファイルロックを受け継ぐ

#### 制限事項
- ロック対象は常にファイル全体
- アドバイザリロックしか使用できない
- `flock(2)`のファイルロックに対応しないNFS実装が多く存在する

#### 引数
- `fd`、`operation`を指定する
  - `fd` - 指定のファイルへのファイルディスクリプタ
  - `operation` - ロック種類を示すマクロ定数
    - `LOCK_SH` - 共有ロック - 同時に複数プロセスがロックできる
    - `LOCK_EX` - 排他ロック - 同時に1プロセスのみがロックできる
    - `LOCK_UN` - アンロック
    - `LOCK_NB` - ノンブロッキング動作でロックを試みる

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## `fcntl(2)`
- Sytem V由来
- 指定のファイル内の範囲を指定し、その部分だけロックする(レコードロック)
- 複製されたファイルディスクリプタ(`dup(2)`、`fork(2)`など)も
  元のファイルディスクリプタと同じファイルロックを受け継がない
  - ただし`exec`の場合は受け継ぐ
- プロセス内の全スレッドがレコードロックを共有する
- レコードロックはプロセス、i-nodeそれぞれと対応関係を持つ
  - ただしファイルディスクリプタをクローズした場合、自プロセスが獲得したファイルのロックは
    どのファイルディスクリプタで獲得したかに関わらず、全て開放される

```c
struct flock flockstr;

fcntl(fd, cmd, &flockstr)
```

### `fd`
- 指定のファイルへのファイルディスクリプタ

### `cmd`
- ファイルロック操作
  - `F_SETLK` - 指定の範囲に対してロックを獲得または解放する
  - `F_SETLKW` - 指定の範囲に対してロックを獲得または解放する
    - 対象ロック範囲と重複して他プロセスが一致しないロックを設けていた場合は処理をブロックする
  - `F_GETLK` - 指定のロックを獲得できるか調べる

### `flock`構造体
- 獲得・解放するロックの内容を示す

```c
struct flock {
  short l_type;   // ロック種類
  short l_whence; // l_startの意味
  off_t l_start;  // ロック開始オフセット
  off_t l_len;    // ロック範囲バイト数
  pid_t l_pid;    // ロック獲得中のプロセスID
};
```

- `l_type` - ロック種類
  - `F_RDLCK` - リードロック(共有ロック相当)
  - `F_WRLCK` - ライトロック(排他ロック相当)
  - `F_UNLCK` - アンロック

- `l_whence` - 範囲開始地点
  - `SEEK_SET` - ファイルの先頭
  - `SEEK_CUR` - 現在のファイルオフセット
  - `SEEK_END` - ファイルの末尾

### 制限事項
- アンロックは常に成功する
- ファイル内の同じ範囲に対してはプロセスは一種類のロックしか保持できない
- 同じファイルを複数の異なるファイルディスクリプタからロックしても
  ブロックすることはない
- 既存のロック範囲内に異なる種類のロックを新たに設けると
  既存のロックは分割され、新たなロックの前後に並ぶ
- 既存のロックに連続するor重なるように同種のロックを新たに設けると
  ロックは連結されてひとつのロックになる

### ロックの上限
- システム全体のレコードロック数が上限に達すると`fcntl(2)`は`ENOLCK`を返す
- Linuxでは上限はなくメモリを使用できる限りレコードロックを設けることができる

### ロックの性能
- ロックを管理するカーネル内のデータ処理及びカーネルデータ内でのロックの位置に依存する
  - 同一プロセスの場合、カーネルは既存のロックに隣接する同種の新規ロックをマージする必要がある
  - 新規ロックは自プロセスの一つ以上の既存ロックに置き換わる可能性がある
  - 既存ロック内にロック種類が異なる新規ロックを獲得すると、既存ロックを分割する
- オープンしたファイルはそれぞれに対応するロック情報のリンクリストを持つ
  - リスト内のロック情報はプロセスIDを第一キーに、開始オフセットを第二キーにソートされる
  - ファイルの新規ロック時はリストをシーケンシャルにたどって既存ロックとの衝突を検査し、
    リンクリストへデータを追加する

### 強制ロック
- 全てのファイルIO時に対象ファイル部分がロックされている場合、
  既存ロックと衝突しないか検査する
- ファイルシステムマウント時に強制ロックを使用するよう設定する

```
$ mount -o mand /dev/sda10 /testfs
```

- 強制ロック中のファイルに対して`read(2)` / `write(2)`が競合した場合
  - ブロッキングモードの場合はシステムコールがブロックする
  - ノンブロッキングモードの場合は`EAGAIN`エラーが発生する

## プログラム実行を一インスタンスに制限する(デーモン)
- 実行中の同じプログラムがシステム上に同時に存在することを禁止する
- デーモンが標準ディレクトリ下にファイルを作成し、ライトロックする
- 実行中はファイル録を保持し、終了時はファイルを削除する
- デーモンは自身のプロセスIDをロックファイルへ書き込む
- ファイル名には`.pid`拡張子を付加する