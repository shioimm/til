# コマンドラインパラメータ
- `main()`関数が受け取る引数
  - `int argc` - 引数の数
  - `char *argv[]` - 引数の配列の先頭ポインタ
    - NULLで終端する文字列へのポインタを配列の要素とする
    - `argv[0]`は`main()`を実行したプログラム自身の名前

## コマンドラインパラメータへのアクセス
- `main()`関数の引数としてアクセスする
- `/proc/PID/cmdline`を参照する
  - コマンドラインパラメータがNULLで区切られた状態で格納されている
- (glibc)`main()`を実行したプログラム自身の名前は
  `program_inovation_name` / `program_inovation_short_name`でアクセスできる
  - 機能検査マクロ`_GNU_SOURCE`の定義が必要

## 参照
- Linuxプログラミングインターフェース 6章
