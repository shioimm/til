# 変更まとめ
#### parse.y

```c
// トークンの追加
%token <id> tINCOP_ASGN "increment-operator-assignment" /* ++ */
```

```c
// トークンの優先度の定義
%right '=' tOP_ASGN tINCOP_ASGN
```

```c
// パーサ
arg : // ...
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
    ;
```

```c
static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  switch (c = nextc(p)) {
  // ...
  case '+':
    //...
    if (c == '+') {
      set_yylval_id('+');
      SET_LEX_STATE(EXPR_BEG);
      return tINCOP_ASGN;
    }
    // ...
  }
  // ...
}
```

#### ext/ripper/eventids2.c

```c
static ID
ripper_token2eventid(enum yytokentype tok)
{
#define O(member) (int)offsetof(ripper_scanner_ids_t, ripper_id_##member)+1
  static const unsigned short offsets[] = {
    // ...
    [tINCOP_ASGN] = O(op),
    // ...
  }
}
```
