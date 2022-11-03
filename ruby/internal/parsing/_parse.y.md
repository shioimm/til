# parse.y

```
// 定義部
%{
  ...
%}

%union {
  ...
}

%token ...

%type  ...

// 構文規則部
%%
...

// ユーザ定義コード部
//   パーサインターフェイス
//   スキャナ (文字列処理)
//   構文木の構築
//   意味解析
//   ローカル変数の管理
//   IDの実装
%%
...
```

### コーディングルール

| 種類                     | 規則       | 例                                     |
| -                        | -          | -                                      |
| 非終端記号               | 小文字     | stmt                                   |
| 予約語を表す終端記号     | k + 大文字 | kIF (if) 、kDEF (def)                  |
| 予約語以外を表す終端記号 | t + 大文字 | tIDENTIFIER (変数名) 、tINTEGER (数字) |

### parse.yに頻出の語

| 意味             | 例                                       |
| -                | -                                        |
| プログラム全体   | program, prog, file, input, stmts, whole |
| 文 (構文木の幹)  | stmt, statement                          |
| 式 (構文木の枝)  | expr, expression                         |
| 項 (構文木の葉)  | prim, primary                            |
| 代入の左辺       | lhs (left hand side)                     |
| 代入の右辺       | rhs (right hand side)                    |
| 関数呼び出し     | funcall, call, function                  |
| メソッド呼び出し | method, call                             |
| 引数             | arg, argument                            |
| 関数定義         | defun, definition, function, fndef       |
| 宣言一般         | declaration, decl                        |
| ( )              | paren, parentheses                       |
| { }              | braces                                   |
| [ ]              | brackets                                 |
| 文を終端する記号 | terms, terminators                       |
| 省略可能         | opt, optional                            |

## `lex_state`
- スキャナの状態 (今スキャナを動作させたらどんな振舞いをするか) を表すための概念
  - `lex_states` - スキャナの状態の種類を表現するenum
  - `lex_state_e` - スキャナの状態の値を表現するenum
  - `IS_lex_state_...` - スキャナの状態を真偽値で表現するマクロ
  - `parser_set_lex_state()` / `SET_LEX_STATE` - スキャナの状態を更新する関数・マクロ

| 種類           | 意味                       |
| -              | -                          |
| `EXPR_BEG`     | 式の先頭にいる             |
| `EXPR_END`     | 式の末尾にいる             |
| `EXPR_ENDARG`  |                            |
| `EXPR_ENDFN`   |                            |
| `EXPR_ARG`     | メソッドの引数の前にいる   |
| `EXPR_CMDARG`  |                            |
| `EXPR_MID`     |                            |
| `EXPR_FNAME`   | メソッド名の前にいる       |
| `EXPR_DOT`     | 式の中の`.`の後にいる      |
| `EXPR_CLASS`   |                            |
| `EXPR_LABEL `  |                            |
| `EXPR_LABELED` |                            |
| `EXPR_FITEM`   |                            |

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
