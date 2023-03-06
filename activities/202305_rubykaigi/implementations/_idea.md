# 実装案
### パーサパターン
#### 動作フロー
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - トークン`+`を読み込む
    - lex.pcurを一つ進めて次のトークンを取得
    - 次のトークンが`+`の場合、インクリメント演算子を表すトークン`tINCOP_ASGN`をシフト
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う

#### やること
- `++`を表現するトークン`tINCOP_ASGN`を追加
- `yylex()`内に`tINCOP_ASGN`を返すロジックを追加
- 構文規則`var_lhs lex_ctxt tINCOP_ASGN`を追加
- 構文規則`var_lhs lex_ctxt tINCOP_ASGN`のアクションで1を表すNODE構造体を作成し、
  `$$ = new_op_assign(p, $1, $3, <1を表すNODE構造体>, $2, &@$);`を実行

```c
// parse.y

%token <id> tINCOP_ASGN "incremental-operator-assignment"

%%

arg : var_lhs lex_ctxt <TokenName>
{
  // tINTEGER (1) が読み込まれてからarg_rhsに還元されるまでの処理を実行する
  // 1を表すNODE構造体を作成し、それを利用してset_number_literal()内の処理を実装する
  //
  // static enum yytokentype
  // set_number_literal(struct parser_params *p, VALUE v, enum yytokentype type, int suffix)
  // {
  //   set_yylval_literal(v);
  //   SET_LEX_STATE(EXPR_END);
  //   return type;
  // }

  /*%%%*/
  // static NODE *
  // new_op_assign(struct parser_params *p, => p
  //               NODE *lhs,               => $1 (var_lhsの値)
  //               ID op,                   => $2 (<TokenName>の値: set_yylval_id('+');)
  //               NODE *rhs,               => 数値1を表すノード
  //               struct lex_context ctxt, => $3 (lex_ctxtの値)
  //               const YYLTYPE *loc)      => &@$
  $$ = new_op_assign(p, $1, $3, NODE *rhs (数値1を表すノード), $2, &@$);

  // Ripper: set_yylval_literal(v); + SET_LEX_STATE(EXPR_END);
  /*%
  // Ripper用の実装
  %*/
}

%%

static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  while (1) {
    switch (c = nextc(p)) {
    // ...
    case '+':
      c = nextc(p);
      if (c == '+') {
        set_yylval_id('+');
        SET_LEX_STATE(EXPR_BEG);
        return tINCOP_ASGN;
      }
    }
  }
}
```

### スキャナパターン
#### 動作フロー
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - トークン`+`を読み込む
    - 次のトークンをpeek
      - 次のトークンが`+`の場合: インクリメント演算子であることを示すフラグをONにし、`tOP_ASSIGN`をシフト
    - 次のトークン`+`を読み込む
      - インクリメント演算子であることを示すフラグがONかつ行末の場合: `set_integer_literal()`を実行
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う

#### やること
- `yylex()`内に動作フローを実現する処理を追加

#### メソッド呼び出しパターン
(レシーバが変数かそれ以外かによって処理を変更しなければならないため頓挫)

1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - [要作業] `++`に対してメソッド呼び出しを表すトークンを返す
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
    - [要作業] `method_call`規則に`| primary_value <TokenName>`を追加する
    - [要作業] `.`を必要としない改造版`new_qcall()` / `NEW_QCALL` (`NODE_CALL`を返す) を追加する
    - [要作業] `| primary_value <TokenName>`のアクションで改造版`new_qcall()`を呼ぶ
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う
    - スタックにレシーバをpush
    - スタックに引数1をpush
    - メソッド`+`を実行
    - [要作業] Numericに`++`メソッド定義
