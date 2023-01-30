# `lex_state`
- スキャナの状態 (今スキャナを動作させたらどんな振舞いをするか) を表すための概念
  - スキャナの状態の種類: `lex_state_bits` (enum)
  - 現在のスキャナの状態: `parser_params`構造体の`lex`メンバの`state`メンバ
  - スキャナの状態の確認: `IS_lex_state(...)` / `IS_lex_state_...`
  - スキャナの状態の更新: `parser_set_lex_state()` / `SET_LEX_STATE`
- スキャナの状態によってトークンの切りかたを変えるために使用する

| 種類           | 意味                                                                               |
| -              | -                                                                                  |
| `EXPR_BEG`     | 式の先端 (`\n`、`(`、`{`、`[`、`!`、`?`、`:`、`,`、演算子、`op=`などの直後) にいる |
| `EXPR_MID`     | 予約語`return`、`break`、`next`、`rescue`の直後にいる                              |
| `EXPR_END`     | 式が終端可能なところにいる                                                         |
| `EXPR_ENDARG`  | `tLPAREN_ARG`に対応する閉じ括弧の直後にいる                                        |
| `EXPR_ENDFN`   |                                                                                    |
| `EXPR_ARG`     | メソッド呼び出しのメソッド名を表す要素の直後または`[`の直後にいる                  |
| `EXPR_CMDARG`  | 通常形式のメソッド呼び出しの最初の引数の前にいる                                   |
| `EXPR_FNAME`   | メソッド名の前 (`def`、`alias`、`undef`、シンボル`:`の直後) にいる                 |
| `EXPR_DOT`     | メソッド呼び出しの`.`の直後にいる                                                  |
| `EXPR_CLASS`   | 予約語`class`の直後にいる                                                          |
| `EXPR_LABEL`   |                                                                                    |
| `EXPR_LABELED` |                                                                                    |
| `EXPR_FITEM`   |                                                                                    |

## 参照
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
