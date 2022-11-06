# yylex() '+'

```c
// p = struct parser_params *p

case '+':
  c = nextc(p);

  // lex_stateがEXPR_FNAMEもしくはEXPR_DOT (L7569)
  // (def +が再定義された場合、もしくは<Receiver>.+が実行された場合)
  if (IS_AFTER_OPERATOR()) {
    SET_LEX_STATE(EXPR_ARG);
    if (c == '@') {
      return tUPLUS;
    }
    pushback(p, c);
    return '+';
  }

  // <Receiver>+= が実行された場合
  if (c == '=') {
    set_yylval_id('+'); // yylval.id = ('+') (L5937)
    SET_LEX_STATE(EXPR_BEG);
    return tOP_ASGN;
  }

  // 通常はIS_BEGがtrueになっていそう
  if (IS_BEG() || (IS_SPCARG(c) && arg_ambiguous(p, '+'))) {
    SET_LEX_STATE(EXPR_BEG);
    pushback(p, c); // p->lex.pcur-- (L6799)
    if (c != -1 && ISDIGIT(c)) {
      return parse_numeric(p, '+');
    }
    return tUPLUS;
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
