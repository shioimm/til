# 変数`n`のスキャン

```c
static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  while (1) {
    switch (c = nextc(p)) {
    // ...
    case '+':

    SET_LEX_STATE(EXPR_BEG);
    pushback(p, c);
    return warn_balanced('+', "+", "unary operator");
    }
    // ...
  }
  // ...
}
```

```c
// i + n
// tok = '+'
// op  = "+"
// syn = "unary operator"

// コンマ演算子 (左辺を評価して捨て、その後右被演算子を評価する)
#define warn_balanced(tok, op, syn) (
  (void)(!IS_lex_state_for(last_state, EXPR_CLASS|EXPR_DOT|EXPR_FNAME|EXPR_ENDFN) &&
         space_seen &&
         !ISSPACE(c) &&
         (ambiguous_operator(tok, op, syn), 0)),
  (enum yytokentype)(tok)
)

// 条件に応じて ambiguous_operator() を実行し、その後 (enum yytokentype)(tok) を返す

#define IS_lex_state_for(x, ls) ((x) & (ls))
#define ambiguous_operator(tok, op, syn) (
  rb_warning0("`"op"' after local variable or literal is interpreted as binary operator"),
  rb_warning0("even though it seems like "syn"")
)
```
