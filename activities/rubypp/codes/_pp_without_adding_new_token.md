# 実装メモ
1. トークン`+`を読み込む
2. 次のトークンをpeek
    - 次のトークンが`+`の場合: 次のトークンが`=`の場合と同じ処理を実行 (一つめの`+`で`tOP_ASSIGN`を返す)
    - 次のトークンが`+`以外の場合: 後続の処理を実行
4. 次のトークン`+`を読み込む
5. `set_integer_literal()`を実行

```c
int peek_char = 0;
int is_increment_op = 0;

static enum yytokentype
parser_yylex(struct parser_params *p)
{
  // ...
  switch (c = nextc(p)) {
  // ...
  case '+':
    peek_char = peekc(p);

    if (peek_char == '+') {
      is_increment_op = 1;
      set_yylval_id('+');
      SET_LEX_STATE(EXPR_BEG);
      return tOP_ASGN;
    } else {
      peek_char = peekc_n(p, 1);
      if (is_increment_op && peek_char == -1) {
        return set_integer_literal(p, rb_cstr_to_inum("1", 16, FALSE), 0);
      }
    }
    // ...
  }
  // ...
}
```

- 元々は`return parse_numeric(p, '1');`にしていたが、トークンバッファの確保等の処理が不要なため
  `return set_integer_literal(p, rb_cstr_to_inum("1", 16, FALSE), 0);`へ変更

```c
#define peekc(p) peekc_n(p, 0)
#define peekc_n(p,n) (lex_eol_n_p(p, n) ? -1 : (unsigned char)(p)->lex.pcur[n])
#define lex_eol_n_p(p,n) ((p)->lex.pcur+(n) >= (p)->lex.pend)
```
