# 実装メモ
1. トークン`+`を読み込む
2. 次のトークンをpeek
    - 次のトークンが`+`の場合: 次のトークンが`=`の場合と同じ処理を実行 (一つめの`+`で`tOP_ASSIGN`を返す)
    - 次のトークンが`+`以外の場合: 後続の処理を実行
4. 次のトークン`+`を読み込む
5. `set_integer_literal()`を実行

```c
int peek_char = 0;

static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  switch (c = nextc(p)) {
  // ...
  case '+':
    peek_char = peekc(p);

    if (peek_char == '+') {
      set_yylval_id('+');
      SET_LEX_STATE(EXPR_BEG);
      return tOP_ASGN;
    } else {
      peek_char = peekc_n(p, 1);
      if (peek_char == -1) {
        return parse_numeric(p, '1'); // WARN: 式が複数行に渡る場合、SyntaxErrorになる
      }
    }
    // ...
  }
  // ...
}
```

- 1回目の`+`で次のトークンをpeekし、次のトークンも`+`だった場合にtruthyな値を保持するフラグが必要
- 読み込んだトークンが`+`であり、かつフラグがtruthyであり、かつその次のトークンが-1である場合
  `else`以下を実行するようにする

```c
#define peekc(p) peekc_n(p, 0)
#define peekc_n(p,n) (lex_eol_n_p(p, n) ? -1 : (unsigned char)(p)->lex.pcur[n])
#define lex_eol_n_p(p,n) ((p)->lex.pcur+(n) >= (p)->lex.pend)
```
