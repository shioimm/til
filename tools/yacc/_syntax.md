# 文法ファイル `*.y`

```
// 定義部
%{
  ...
%}

%union {
  ...
}

%token <unionで定義した型>終端記号1
%token <unionで定義した型>終端記号2 ...

%type  <unionで定義した型>非終端記号1 非終端記号2...

%left     ...
%right    ...
%nonassoc ...

// 構文規則部
%%
<規則名>: <定義> { アクション }
...

// ユーザ定義部
%%
...
```

### 定義部 (宣言部)
- 構文規則部やプログラム部で使用する変数、関数、マクロを宣言する
  - `%{ %}`内に任意のCプログラムを記述できる
  - Lexを用いておりLexでも宣言部を記述している場合、yaccの宣言部によって重複して宣言される
- `%union` - 各記号の値の型を表す共用体の宣言 (`%union`で宣言した型がYYSTYPE型として扱われる)
- `%token` - 終端記号とその型の宣言
  - 終端記号 - スキャナから送られてくる記号 (e.g. `IF`、`THEN`、`END`、`'='`)

```
%token [<Tag>] Name [Number] [Name [Number]]...

// 値Numberが割り当てられた<Tag>メンバ型のNameトークン
```

- `%type` - 非終端記号とその型の宣言
  - 非終端記号 - パーサ内で定義される記号 (e.g. `if_stmt`、`expr`、`stmt`)
- `%left` - 他のトークンと左結合するトークンの宣言 (優先度が低い順)
- `%right` - 他のトークンと左結合するトークンの宣言 (優先度が低い順)
- `%nonassoc` - 他のトークンと結合できない演算子の宣言

### 構文規則部
- 構文規則とその規則で還元が起きるときのアクションをBNFで記述する
  - 見ための解析のために必要な文法
  - アクションの実行に必要なもの
- yaccは規則部に記述した文法を`yyparse()`関数に変換する

```
/* e.g. */
/* stmt (文) の定義 */
stmt    : if_stmt               /* if_stmt (if文) */
        | IDENTIFIER '=' expr   /* 代入           */
        | expr                  /* expr (式)      */

/* if_stmt (if文の定義) */
if_stmt : IF expr THEN stmt END
        | IF expr THEN stmt ELSE stmt END

/* expr (式) の定義 */
expr    : IDENTIFIER            /* 変数参照 */
        | NUMBER                /* 整数定数 */
        | funcall               /* funcall (関数呼び出し) */

/* funcall (関数呼び出し) の定義 */
funcall : IDENTIFIER '(' args ')'

/* args (引数) の定義 */
args    : expr
```

### ユーザ定義部 (プログラム部)
- 構文解析で使用する補助関数を記述する
- Lexを使用する場合はここで`#include "lex.yy.c"`し字句解析プログラムを取り込む
- エラー表示関数`yyerror()`は必ずユーザー定義が必要

```c
%{
  ...
%}

%union {
  int val;
}

%token <val> NUMBER

%type  ...

%%
<規則名>: <定義> { アクション }
...

%%
...
```

## 参照
- [yacc](https://ja.wikipedia.org/wiki/Yacc)
- [第9章 速習yacc](https://i.loveruby.net/ja/rhg/book/yacc.html)
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- コンパイラ入門 構文解析の原理とlex/yacc, C言語による実装
