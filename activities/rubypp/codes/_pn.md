# +n実装メモ

```c
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
        int peek_char = peekc(p);
        int increment_count = 0;

        while (peek_char == '+') {
            printf("%c\n", peek_char);
            c = nextc(p);
            peek_char = peekc(p);
            increment_count++;
            printf("%d\n", increment_count);
        }

        set_yylval_id('+');
        SET_LEX_STATE(EXPR_BEG);
        return tINCOP_ASGN;
      }
    }
  }
}
```
