# parse.y
## YYSTYPE定義

```c
%union {
  VALUE val;
  NODE *node;
  ID id;
  int num;
  st_table *tbl;
  const struct vtable *vars;
  struct rb_strterm_struct *strterm;
  struct lex_context ctxt;
}
```

## 入力バッファ
- ソースプログラムを読み込むためのバッファ
- `parser_params`構造体の`lex`メンバ

#### 読み込みインターフェース
- `nextc()`    - ポインタを進め、現在の位置にある文字を読み込む (入力バッファが空の場合は行を進める)
- `pushback()` - ポインタを戻し、一文字書き戻す
- `peek()`     - ポインタを進めずに次の文字をチェックする

## トークンバッファ
- 入力バッファから1バイトずつ読み込み、トークンが一つ切り出せるまで文字列を保管しておくためのバッファ
- `parser_params`構造体の`tokenbuf`メンバ
  - `parser_params`構造体の`tokidx`メンバ - トークンの末尾
  - `parser_params`構造体の`toksiz`メンバ - バッファ長

#### 読み込みインターフェース
- `newtok()` - `parser_params`からたどれるトークン用のバッファを確保する
- `tokadd()` - バッファに一文字を足す
- `tokfix()` - バッファを終端させる
- `tok()`    - バッファリングしている文字列の先頭へのポインタ
- `toklen()` - バッファリングしている文字列の長さ

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
