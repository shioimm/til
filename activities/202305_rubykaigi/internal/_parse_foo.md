# 暗黙の`self`に対する`foo`

```ruby
def foo
end

foo()
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
    // ...
  }
  // ...

  ident = tokenize_ident(p, last_state); // トークンに紐づける値を導出する
  if (result == tCONSTANT && is_local_id(ident)) result = tIDENTIFIER;
  // ...
  return result; // トークン: tIDENTIFIER / 値 T_FIXNUM 8312 (putsのシンボル値)
}
```

```c
static ID
tokenize_ident(struct parser_params *p, const enum lex_state_e last_state)
{
  ID ident = TOK_INTERN();
  set_yylval_name(ident); // (yylval.id = (x)) yylval.id にメソッド名を渡す
  return ident;
}

// #define TOK_INTERN() intern_cstr(tok(p), toklen(p), p->enc)
// #define intern_cstr(n,l,en) rb_intern3(n,l,en)

// symbol.c
// ID
// rb_intern3(const char *name, long len, rb_encoding *enc)
// {
//   VALUE sym;
//   struct RString fake_str;
//   VALUE str = rb_setup_fake_str(&fake_str, name, len, enc);
//   OBJ_FREEZE(str);
//   sym = lookup_str_sym(str);
//   if (sym) return rb_sym2id(sym);
//   ...
// }
```

## 構文解析

```c
operation   : tIDENTIFIER
fcall       : operation
            {
              $$ = NEW_FCALL($1, 0, &@$);  // ノードNODE_FCALLを作る
              nd_set_line($$, p->tokline); // ノードのflagsを設定 (node.h)
              /*% %*/
              /*% ripper: $1 %*/
            }
method_call : fcall paren_args
            {
              /*%%%*/
              $$ = $1;                         // $1 = ノードNODE_FCALL
              $$->nd_args = $2;                // 引数ノードを nd_args に持たせる
              nd_set_last_loc($1, @2.end_pos); // ((n)->nd_loc.end_pos) = (v) (node.h)
              /*% %*/
              /*% ripper: method_add_arg!(fcall!($1), $2) %*/
            }
primary     : method_call
arg         | primary
            {
              $$ = $1; // $1 = ノードNODE_FCALL
            }
```
