# メモリ管理
## ヒープ上のメモリの割り当て
### `malloc(3)`
- 指定したバイト数のメモリを割り当てる
- 割り当てられた領域の初期値は不定

#### `brk`と比較した際の利点
- マルチスレッドアプリケーションから利用可能
- 小さいサイズの領域も割り当て可能
- 内部でフリーリストを管理し、以降の割り当てに再利用するため、メモリを自由に解放できる

#### `malloc(3)`ファミリ
- `mallopt(3)` - `malloc(3)`のパラメータを操作
- `mallinfo(3)` - `malloc(3)`が割り当てたメモリの統計情報をまとめた構造体を返す

#### 引数
- `size`を指定する
  - `size` - 割り当てを行う領域のサイズ

#### 返り値
- 割り当てた領域の先頭アドレスへのポインタを返す
  - エラー時はNULLを返す(プログラムブレークが上限に達した場合など)

### `free(3)`
- 指定されたメモリを解放する

#### 引数
- `ptr`を指定する
  - `ptr` - 事前に`malloc(3)`などで返されたポインタ

### `calloc(3)`
- 指定した数の要素を格納できるバイト数のメモリを割り当てる
- 割り当てられた領域の初期値は0

#### 引数
- `numitems` / `size`を指定する
  - `numitems` - 配列の要素数
  - `size` - 割り当てを行う領域のサイズ

#### 返り値
- 割り当てた領域の先頭アドレスへのポインタを返す
  - エラー時はNULLを返す(プログラムブレークが上限に達した場合など)

### `realloc(3)`
- `malloc(3)`が割り当てた領域のサイズを変更する

#### 引数
- `ptr` / `size`を指定する
  - `ptr` - サイズを変更する領域のポインタ
  - `size` - 割り当てを行う領域のサイズ

#### 返り値
- 割り当てた新しい領域の先頭アドレスへのポインタを返す
  - エラー時はNULLを返す(プログラムブレークが上限に達した場合など)

## スタック上のメモリ割り当て
### `alloca(3)`
- スタックフレーム上に指定したバイト数のメモリを割り当てる
- 確保したメモリはreturnによって自動的に解放される

#### `alloca(3)`が実装されていない環境で擬似的に`alloca(3)`を実装する例
1. `malloc(3)`でヒープにメモリを割り当てる
2. `alloca(3)`を呼び出した関数と割り当てたアドレスの組をグローバルなリストに登録する
3. 次に`alloca(3)`が呼び出された時点でリストをチェックし、
   既に終了した関数で割り当てたメモリがある場合は`free(3)`で解放する

#### 引数
- `size`を指定する
  - `size` - 割り当てを行うスタック上のメモリサイズ

#### 返り値
- 割り当てた領域の先頭アドレスへのポインタを返す

## 参照
- 例解UNIX/Linuxプログラミング教室P185-224
- 詳解UNIXプログラミング第3版 7. プロセスの環境 / 8. プロセスの制御 / 9. プロセスの関係
- Linuxプログラミングインターフェース 6章
