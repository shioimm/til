# 実装メモ
### パーサパターン
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - `++`を表現するトークン`TokenName`を追加
    - `++`を読み込み時、`<TokenName>`をシフト
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
    - `arg`規則に`| var_lhs lex_ctxt <TokenName>`を追加する
    - 追加した構文規則にアクションを追加
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う

```c
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
```

```c
// parse.y

%token <id> tINCOP_ASGN        "incremental-operator-assignment" /* ++ */
// ...
%right '=' tOP_ASGN tINCOP_ASGN
// ...

| var_lhs lex_ctxt tINCOP_ASGN
  {
    /*%%%*/
    VALUE v = rb_cstr_to_inum("1", 16, FALSE);
    NODE *x = NEW_LIT(v, &NULL_LOC);
    YYLTYPE _cur_loc;
    rb_parser_set_location(p, &_cur_loc);
    yylval.node = (x);

    RB_OBJ_WRITTEN(p->ast, Qnil, x);

    SET_LEX_STATE(EXPR_END);

    $$ = new_op_assign(p, $1, $3, x, $2, &@$);

    // Ripper: set_yylval_literal(v); + SET_LEX_STATE(EXPR_END);
    /*%
    VALUE v = rb_cstr_to_inum("1", 16, FALSE);
    add_mark_object(p, (v));

    VALUE v1, v2, v3, v4;
    v1 = (yyvsp[-2].val);
    v2 = (yyvsp[0].val);
    v3 = v;
    v4 = dispatch3(p, v1, v2, v3);
    (yyval.val) = v4;

    SET_LEX_STATE(EXPR_END);
    %*/
  }

// ...

static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  if (c == '+') {
    set_yylval_id('+');
    SET_LEX_STATE(EXPR_BEG);
    return tINCOP_ASGN;
  }
  // ...
}

// ext/ripper/eventids2.c

static ID
ripper_token2eventid(enum yytokentype tok)
{
#define O(member) (int)offsetof(ripper_scanner_ids_t, ripper_id_##member)+1
  static const unsigned short offsets[] = {
    // ...
    [tINCOP_ASGN]  = O(op),
    // ...
  }
}
```

### スキャナパターン
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - 次のトークンが`+`だった場合: pcurを一つ進める (最初の`c = next(p);`)
      - 次のトークンが`\n`だった場合: pcurを二つ戻す
        - 二つ前のトークンが`+`だった場合: pcurを一つ進める + `parse_numeric(p, '1')`を返す
        - 二つ前のトークンが`+`以外だった場合: pcurを一つ進める + 条件式から抜ける (規定の処理に進む)
      - 次のトークンが`+`だった場合: pcurを一つ戻し、`tOP_ASGN`を返す (前方の'+')
      - 次のトークンが`+` / `\n`以外だった場合: 規定の処理に進む
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う

```c
// parse.y

%token <id> tINCOP_ASGN "operator-assignment"

%%

arg : var_lhs tINCOP_ASGN lex_ctxt arg_rhs
{
  $$ = new_op_assign(p, $1, $2, $4, $3, &@$);
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

```c
// parse.y

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
          return tOP_ASGN;
      }
    }
  }
}
```

#### メソッド呼び出しパターン
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
