# 文法ファイル `*.y`

```
// 定義部
%{
  ...
%}
%union ...
%token ...
%type  ...

// 構文規則部
%%
...

// ユーザ定義部
%%
...
```

### 定義部 (宣言部)
- 構文規則部やプログラム部で使用する変数、関数、マクロを宣言する
  - `%{ %}`内に任意のCプログラムを記述できる
  - Lexを用いておりLexでも宣言部を記述している場合、yaccの宣言部によって重複して宣言される
- `%union` - 各記号の値の型を表す共用体の宣言
- `%token` - 終端記号とその型の宣言
- `%type` - 非終端記号とその型の宣言

### 構文規則部
- 構文規則とその規則で還元が起きるときのアクションを記述する
  - 見ための解析のために必要な文法
  - アクションの実行に必要なもの
- yaccは規則部に記述した文法を`yyparse()`関数 (狭義のパーサ・構文木を生成する) に変換する
- `yyparse()`関数は字句解析を行わないため、ユーザーは別途字句解析関数`yylex()`関数を用意する必要がある
- `yyparse()`関数は`yylex()`関数を繰り返し呼びながら入力文字列全体の字句解析と構文解析を行う
  - 入力列全体の字句解析・構文解析に成功した場合は0、解析エラーを発見した場合は1を返す

### ユーザ定義部 (プログラム部)
- 構文解析で使用する補助関数を記述する
- Lexを使用する場合はここで`#include "lex.yy.c"`し字句解析プログラムを取り込む
- エラー表示関数`yyerror()`は必ずユーザー定義が必要

## 文法ファイルに頻出の単語

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

## 参照
- [yacc](https://ja.wikipedia.org/wiki/Yacc)
- [第9章 速習yacc](https://i.loveruby.net/ja/rhg/book/yacc.html)
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- コンパイラ入門 構文解析の原理とlex/yacc, C言語による実装
