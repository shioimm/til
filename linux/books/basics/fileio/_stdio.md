# 標準入出力
- 参照: 例解UNIX/Linuxプログラミング教室P149-184
- 参照: 詳解UNIXプログラミング 第3版 5. 標準入出力ライブラリ
- 参照: Linuxによる並行プログラミング入門 第3章 ファイル入出力 3.3

## TL;DR
- C言語における標準的な入出力機能(`<stdio.h>`)
  - `fopen` / `fclose`(開け閉め)
  - `fgetc` / `fputc` etc(読み書き)
  - `fseeko` etc(カレントファイルオフセットを移動させる操作)
- ライブラリ関数によって提供される
  - 低水準入出力機能を提供するシステムコールを利用して実装されている
- 各種標準入出力ストリームには対応するファイルディスクリプタがあり、`fileno`で取得できる

### 標準入出力における注意点
- バッファの状態を意識する
  - `fflush`          - ストリームに出力したデータをカーネルに渡す場合
  - `fclose` `exit`   - プログラムを終了する場合
  - `fflush` `fclose` - `exec`関数で他のプログラムを実行する場合
  - `fflush`          - `fork`でプロセスを複製する場合
- 一つのファイルディスクリプタを低水準入力と標準入出力で同時に使用しない
- `r+` `w+` `a+`における位置決め
  - 書き操作の後に読み操作をするにはそれらの間で位置決めする必要がある
  - 読み操作の後に書き操作をするにはそれらの間で位置決めする必要がある
    - ファイルがEOFになっている場合を除く

## ストリーム
- 実際のファイルへのアクセス構造体オブジェクト
- ストリームは自身の中に記憶領域(バッファ)を持つ
- 入力ストリーム - 読むためのストリーム
- 出力ストリーム - 書くためのストリーム
- ストリームをオープンすると(`fopen(3)`)`FILE`型オブジェクトへのポインタ(ファイルポインタ)が返る
  - `<stdio.h> stdin` -> `STDIN_FILENO`へのファイルポインタ
  - `<stdio.h> stdout` -> `STDOUT_FILENO`へのファイルポインタ
  - `<stdio.h> stderr` -> `STDERR_FILENO`へのファイルポインタ

### `FILE`型オブジェクトが持つ情報
- 実際の入出力に使用するファイルディスクリプタ
- ストリームのバッファへのポインタ
- バッファサイズ
- バッファ内に現在ある文字数
- エラーフラグなど

## バッファリング
- `read` / `write`の呼び出し回数を削減することで入出力を効率的に行うための仕組み
  - 入出力時にデータが通る途中にある程度の大きさの記憶領域を設ける
  - 一回あたりのデータ入出力をある程度の大きい単位で行い、実際の入出力操作の回数を減らす
- 低水準入力にはバッファリング機能がない
- 標準入出力ライブラリは内部にバッファリング機能を持つ
  - バッファの大きさは`<stdio.h>`に`BUFSIZE`として定義されている
- バッファ用のメモリは`malloc(3)`で確保される
- プロセスが正常に終了すると、全ての標準入出力ストリームはフラッシュ、クローズされる

### フラッシュ
- `write`を呼び出して出力バッファの内容をカーネルに渡すこと
- `fclose`でストリームを閉じる際、そのストリームの出力バッファが自動的にフラッシュされる

### 種類
- 標準エラー出力は常にアンバッファド
- それ以外のストリームのうち、
  端末装置を参照する場合は行バッファリング、
  端末装置を参照しない場合は完全バッファリング

#### 完全バッファリング
- バッファを目一杯使い、満杯になると実際の入出力を行う

#### 行バッファリング
- 改行文字`\n`に出会うと実際の入出力を行う
- バッファサイズは固定されている
  - 一行が長い場合は途中で`read` `write`が呼ばれる
  - 行バッファリング / アンバッファドの入力ストリームから入力する際
    その前に行バッファリングの出力ストリームがすべてフラッシュされる

#### アンバッファド
- ストリームから読むたびに`read`し、ストリームを書くごとに`write`する

## 標準入出力の操作
### ストリームのオープン
- `fopen` / `freopen` / `fdopen` - 標準入出力ストリームのオープン

### 読み書き
#### 文字単位入出力
- `getchar` `putchar` - 標準入出力への読み書き
- `getc` `putc`       - 任意の入出力先への読み書き(マクロ)
- `fgetc` `fputc`     - 任意の入出力先への読み書き(関数)

#### 行単位入出力
- `fgets` `fputs`  - ストリーム <-> プログラムで用意したバッファ間で一行ずつ読み書き
- `gets`  `puts`   - 標準入出力 <-> プログラムで用意したバッファ間で一行ずつ読み書き
  - `gets`は呼び出し側がバッファサイズを指定できないためバッファオーバーフローの危険がある

#### 書式指定による入出力
- 書式付き出力 `%[フラグ][フィールド幅][精度][長さ修飾子]変換種別`
  - フィールド幅 - 変換で用いる最小フィールド幅
  - 精度         - 整数変換における最小桁数
  - 長さ修飾子   - 引数のサイズ
  - 変換種別     - 必須・引数をどのように解釈するか指定
- 書式付き入力 `%[*][[フィールド幅][m][長さ修飾子]変換種別`
  - フィールド幅 - 文字単位での最大フィールド幅
  - `m`          - 代入割付文字・変換結果の文字列を保持するためのメモリバッファの割付を指示
  - 長さ修飾子   - 引数のサイズ
  - 変換種別     - 必須・引数をどのように解釈するか指定
- `fscanf` / `fprintf` - 書式に従い文字列をストリームに入出力
- `scanf` / `printf`   - 書式に従い文字列を標準入出力に入出力
- `sprintf`            - 書式に従い文字列を指定のメモリ領域に保存(`\0`終端)
  - バッファがオーバーフローする場合がある
- `sscanf`             - 書式に従い文字列を引数に指定した文字列から入力

#### 直接入出力(バイナリデータ)
- `fread` / `fwrite`   - ストリーム <-> 指定のメモリ領域間でバイナリデータを入出力
  - バイナリ配列の読み書き
  - 構造体の読み書き
    - 異なるマシン間でのバイナリデータ交換では想定通りに読み取れない場合がある

### 位置決め
- `fseeko` / `ftello`    - カレントファイルオフセットを設定・取得(`lseek`と同じ)
- `rewind`               - ストリームのカレントファイルオフセット・エラー・EOFをリセット
- `fgetspos` / `fsetpos` - `fpos_t`型を使用してカレントファイルオフセットを設定・取得

### バッファリング
- `setbuf` / `setvbuf` - バッファリングの変更

## 一時ファイル
- `tmpnam(3)` - 既存ファイルには一致しない一意なパス名へのポインタを返す
  - 生成したパス名は静的領域に格納され、当該領域へのポインタを関数の値として返す
  - 次に`tmpnam(3)`を呼ぶと当該静的領域を上書きする
  - `tmpfile(3)`の内部で呼び出される
- `tmpfile(3)` - プログラム終了時に自動的に削除される一時バイナリファイルを作成する
- `mkdtemp(3)` - 一意な名前のディレクトリを作成する
- `mkstemp(3)` - 一意な名前のレギュラーファイルを作成する
  - 作成したファイルは自動的に削除されない

## メモリストリーム
- 対応するファイルを持たない標準入出力ストリーム
- ポインタ`FILE`でアクセス可能
- 全ての入出力はメインメモリ内のバッファに対するバイト転送で行われる
- `fmemopen(3)` - メモリストリームの作成
  - メモリストリームへの書き出しストリーム内容のサイズが増えるたびに自動的にNULLバイトが追加される
  - バッファサイズは固定
- `open_memstream(3)` / `open_wmemstream(3)`
  - `open_memstream(3)` - バイトオリエンテーションのメモリストリームの作成
  - `open_wmemstream(3)` - ワイドオリエンテーションのメモリストリームの作成
  - 作成したストリームは書き出し専用
  - 自前のバッファを指定できない
  - ストリームクローズ後にバッファの開放を行う必要がある
  - ストリームへバイトを追加するごとにバッファが増大する
