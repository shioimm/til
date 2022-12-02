# parse.y
## 記号

| 種類                     | 規則       | 例                                                |
| -                        | -          | -                                                 |
| 非終端記号               | 小文字     | stmt                                              |
| 予約語を表す終端記号     | k + 大文字 | kIF (if) 、kDEF (def)                             |
| 予約語以外を表す終端記号 | t + 大文字 | tIDENTIFIER (変数名/メソッド名) 、tINTEGER (数字) |

## 終端記号

| 記号             | 意味                        |
| -                | -                           |
| `tIDENTIFIER`    | "local variable or method"  |
| `tFID`           | "method" (?や!で終わるもの) |
| `tGVAR`          | "global variable"           |
| `tIVAR`          | "instance variable"         |
| `tCONSTANT`      | "constant"                  |
| `tCVAR`          | "class variable"            |
| `tLABEL`         | "label"                     |
| `tINTEGER`       | "integer literal"           |
| `tFLOAT`         | "float literal"             |
| `tRATIONAL`      | "rational literal"          |
| `tIMAGINARY`     | "imaginary literal"         |
| `tCHAR`          | "char literal"              |
| `tNTH_REF`       | "numbered reference"        |
| `tBACK_REF`      | "back reference"            |
| `tSTRING_CONTENT`|  "literal content"          |
| `tREGEXP_END`    |                             |
| `tDUMNY_END`     | "dummy end"                 |


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
- `newtok()` - 新しいトークンを開始する
- `tokadd()` - バッファに文字を足す
- `tokfix()` - バッファを終端する
- `tok()`    - バッファリングしている文字列の先頭へのポインタ
- `toklen()` - バッファリングしている文字列の長さ

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
