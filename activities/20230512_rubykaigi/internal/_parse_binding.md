# `binding`

```ruby
binding
```

## 字句解析

```c
// parse.y

static enum yytokentype
parse_ident(struct parser_params *p, int c, int cmd_state)
{
  enum yytokentype result;
  int mb = ENC_CODERANGE_7BIT;
  const enum lex_state_e last_state = p->lex.state;
  ID ident;
  int enforce_keyword_end = 0;

  do {
    if (!ISASCII(c)) mb = ENC_CODERANGE_UNKNOWN;
    if (tokadd_mbchar(p, c) == -1) return 0;
    c = nextc(p);
  } while (parser_is_identchar(p));

  if ((c == '!' || c == '?') && !peek(p, '=')) {
    // ...
  } else if (c == '=' && IS_lex_state(EXPR_FNAME) && {
    // ...
  } else {
    result = tCONSTANT;  /* assume provisionally */
    pushback(p, c);
  }

  tokfix(p);
  // ...

  if (IS_lex_state(EXPR_BEG_ANY | EXPR_ARG_ANY | EXPR_DOT)) {
    if (cmd_state) {
      SET_LEX_STATE(EXPR_CMDARG);
    }
  }

  // この行でメソッドIDをyylval.idに格納する
  ident = tokenize_ident(p, last_state);

  // この行でトークンをtIDENTIFIERに確定する
  if (result == tCONSTANT && is_local_id(ident)) result = tIDENTIFIER;

  // ...

  return result; // tIDENTIFIER / T_FIXNUM 11336
}

static ID
tokenize_ident(struct parser_params *p, const enum lex_state_e last_state)
{
  ID ident = TOK_INTERN(); // #define TOK_INTERN() intern_cstr(tok(p), toklen(p), p->enc)
  set_yylval_name(ident);  // #define set_yylval_name(x)  (yylval.id = (x))
  return ident;
}
```

## 構文解析

```c
user_variable : tIDENTIFIER
var_ref       : user_variable
primary       : var_ref
arg           : primary
              {
                $$ = $1; // (VCALL@1:0-1:7 :binding)
              }
expr          : arg %prec tLBRACE_ARG
stmt          : expr
top_stmt      : stmt
top_stmts     : top_stmt
              {
                $$ = newline_node($1);
              }
top_compstmt  : top_stmts opt_terms
              {
                $$ = void_stmts(p, $1);
              }
program       : top_compstmt
              {
                if ($2 && !compile_for_eval) {
                  NODE *node = $2;
                  // ...
                  node = remove_begin(node);
                  void_expr(p, node);
                }
                p->eval_tree = NEW_SCOPE(0, block_append(p, p->eval_tree, $2), &@$);
              }
```
