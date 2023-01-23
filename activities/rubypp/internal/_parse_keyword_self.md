# `keyword_self`の切り出し

```c
// parse.y
static enum yytokentype
parser_yylex(struct parser_params *p)
{
  register int c;
  int space_seen = 0;
  int cmd_state;
  int label;
  enum lex_state_e last_state;
  int fallthru = FALSE;
  int token_seen = p->token_seen;

  // ...
  cmd_state = p->command_start;
  p->command_start = FALSE;
  p->token_seen = TRUE;
  token_flush(p);

  retry:
    last_state = p->lex.state;
    switch (c = nextc(p)) {
      // ...
      default:
        if (!parser_is_identchar(p)) {
          compile_error(p, "Invalid char `\\x%02X' in expression", c);
          token_flush(p);
          goto retry;
        }
        newtok(p); // 新しいトークンを開始する
        break;
    }

    return parse_ident(p, c, cmd_state);
}
```

```c
// parse.y
static char*
newtok(struct parser_params *p)
{
  p->tokidx = 0;
  p->tokline = p->ruby_sourceline;
  if (!p->tokenbuf) {
    p->toksiz = 60;
    p->tokenbuf = ALLOC_N(char, 60);
  }
  if (p->toksiz > 4096) {
    p->toksiz = 60;
    REALLOC_N(p->tokenbuf, char, 60);
  }
  return p->tokenbuf;
}
```

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
    if (tokadd_mbchar(p, c) == -1) return 0; // バッファに溜める
    c = nextc(p);
  } while (parser_is_identchar(p));
  // ...

  tokfix(p); // バッファを終端する ((p)->tokenbuf[(p)->tokidx]='\0')
  // ...

  if (mb == ENC_CODERANGE_7BIT && (!IS_lex_state(EXPR_DOT) || enforce_keyword_end)) {
    const struct kwtable *kw; // struct kwtable { short name, id[2], state; };
    kw = rb_reserved_word(tok(p), toklen(p));

    if (kw) {
      enum lex_state_e state = p->lex.state;
      // ...
      SET_LEX_STATE(kw->state);
      // ...
      if (IS_lex_state_for(state, (EXPR_BEG | EXPR_LABELED | EXPR_CLASS))) {
        return kw->id[0];
      }
      // ...
    }
  }

  // ...
}
```

```c
// トークンの読み込み
// parse.y
static int
tokadd_mbchar(struct parser_params *p, int c)
{
  int len = parser_precise_mbclen(p, p->lex.pcur-1);
  if (len < 0) return -1;
  tokadd(p, c);
  p->lex.pcur += --len;
  if (len > 0) tokcopy(p, len);
  return c;
}
```

```c
// 予約語の取得
// parse.y
const struct kwtable *
rb_reserved_word(const char *str, unsigned int len)
{
  return reserved_word(str, len);
}

// lex.c.blt
const struct kwtable *
rb_reserved_word (register const char *str, register size_t len)
{
  static const struct kwtable wordlist[] = { ... };
  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH) {
    register unsigned int key = hash (str, len);

    if (key <= MAX_HASH_VALUE) {
      register int o = wordlist[key].name;
      if (o >= 0) {
        register const char *s = o + stringpool;
        if (*str == *s && !strcmp (str + 1, s + 1))  return &wordlist[key];
      }
    }
  }
  return 0;
}
```
