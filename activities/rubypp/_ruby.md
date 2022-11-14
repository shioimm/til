# Ruby
#### tokenの定義 (L1301)

```c
%token tUPLUS  RUBY_TOKEN(UPLUS)  "unary+"
```

#### Lexer Buffer (`p = struct parser_params *p`) の構造 (L261)

```c
//  lex.pbeg     lex.ptok     lex.pcur     lex.pend
//     |            |            |            |
//     |------------+------------+------------|
//                  |<---------->|
//                      token
```

#### yylvalの定義 (L5912)

```c
#define yylval  (*p->lval) (parser_params構造体のメンバYYSTYPE *lval)
```

#### `SET_LEX_STATE`マクロ

```c
# define SET_LEX_STATE(ls) parser_set_lex_state(p, ls, __LINE__)

// struct parser_params p->lex.state = ls (L10901)
```

#### `IS_BEG`マクロ

```c
#define IS_lex_state_for(x, ls)     ((x) & (ls))
#define IS_lex_state_all_for(x, ls) (((x) & (ls)) == (ls))
#define IS_lex_state(ls)            IS_lex_state_for(p->lex.state, (ls))
#define IS_lex_state_all(ls)        IS_lex_state_all_for(p->lex.state, (ls))

// lex_stateがEXPR_BEG_ANY
// もしくはEXPR_ARG|EXPR_LABELED
#define IS_BEG() (IS_lex_state(EXPR_BEG_ANY) || IS_lex_state_all(EXPR_ARG|EXPR_LABELED))
```

#### `yylex()` (L9813)

```c
case '+':
  c = nextc(p);

  // lex_stateがEXPR_FNAMEもしくはEXPR_DOT (L7569)
  // (def +が再定義された場合、もしくは<Receiver>.+が実行された場合)
  if (IS_AFTER_OPERATOR()) {
    SET_LEX_STATE(EXPR_ARG);
    if (c == '@') {
      return tUPLUS; // トークンtUPLUSをパーサに渡す
    }
    pushback(p, c); // p->lex.pcur-- (L6799)
    return '+'; // トークン'+'をパーサに渡す
  }

  // <Receiver>+= が実行された場合
  if (c == '=') {
    set_yylval_id('+'); // define set_yylval_id(x)  (yylval.id = (x)) (L5937)
    SET_LEX_STATE(EXPR_BEG);
    return tOP_ASGN; // トークンtOP_ASGNをパーサに渡す
  }

  // 通常はIS_BEGがtrueになっていそう
  if (IS_BEG() || (IS_SPCARG(c) && arg_ambiguous(p, '+'))) {
    SET_LEX_STATE(EXPR_BEG);
    pushback(p, c);
    if (c != -1 && ISDIGIT(c)) {
      return parse_numeric(p, '+');
    }
    return tUPLUS; // トークンtUPLUSをパーサに渡す
  }

SET_LEX_STATE(EXPR_BEG);
pushback(p, c);
return warn_balanced('+', "+", "unary operator"); // 警告
```

#### `warn_balanced` -> `ambiguous_operator`

```
'+' after local variable or literal is interpreted as binary operator
even though it seems like unary operator
```

- https://github.com/ruby/ruby/blob/1454f8f219890b8134f68e868d8cb1d0a9d2aa20/parse.y#L9813-L9838
