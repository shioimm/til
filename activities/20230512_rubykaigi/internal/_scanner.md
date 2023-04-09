# スキャナ
```c
// Lexer Buffer (`p = struct parser_params *p`) の構造
//
// lex.pbeg     lex.ptok     lex.pcur     lex.pend
//    |            |            |            |
//    |------------+------------+------------|
//                 |<---------->|
//                     token

struct parser_params {
  // ...

  YYSTYPE *lval;

  struct {
    // ...
    const char *pbeg;
    const char *pcur;
    const char *pend;
    const char *ptok;
    // ...
  }
  // ...
}

// yylval (parser_params構造体のメンバYYSTYPE *lval) の定義
#define yylval  (*p->lval)

// Lex Stateの操作
// ls = struct parser_params p->lex.state
# define SET_LEX_STATE(ls) parser_set_lex_state(p, ls, __LINE__)

// parser_yylex()
static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  case '+':
    c = nextc(p);
    // ...
    if (c == '=') {
      set_yylval_id('+');
      SET_LEX_STATE(EXPR_BEG);
      return tOP_ASGN;
    }
    if (IS_BEG() || (IS_SPCARG(c) && arg_ambiguous(p, '+'))) {
      SET_LEX_STATE(EXPR_BEG);
      pushback(p, c);
      if (c != -1 && ISDIGIT(c)) {
        return parse_numeric(p, '+');
      }
      return tUPLUS;
    }
    SET_LEX_STATE(EXPR_BEG);
    pushback(p, c);
    return warn_balanced('+', "+", "unary operator");
  // ...
}

// next()     -> カーソルを一つ進める
// pushback() -> カーソルを一つ戻す
```

- https://github.com/ruby/ruby/blob/master/parse.y
