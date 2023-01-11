# `parse_numeric(p, '1');`

```c
static enum yytokentype
parse_numeric(struct parser_params *p, int c)
{
  int is_float, seen_point, seen_e, nondigit;
  int suffix;

  is_float = seen_point = seen_e = nondigit = 0;
  SET_LEX_STATE(EXPR_END);
  newtok(p);

  if (c == '-' || c == '+') { prefixが付いている場合の処理 }
  if (c == '0') { 2進数、8進数、(明示的な) 10進数、16進数の場合 }

  for (;;) {
    switch (c) {
      case '0': case '1': case '2': case '3': case '4':
      case '5': case '6': case '7': case '8': case '9':
        nondigit = 0;
        tokadd(p, c);
        break;
      // ...
      default:
        goto decode_num;
    }
    c = nextc(p);
  }

  decode_num:
    pushback(p, c);
    if (nondigit) { 数字以外の記号だった場合の処理 }

    tokfix(p);

    if (is_float) { floatだった場合の処理 }

    suffix = number_literal_suffix(p, NUM_SUFFIX_ALL);
    return set_integer_literal(p, rb_cstr_to_inum(tok(p), 10, FALSE), suffix);
}
```

1. `parser_params`からたどれるトークン用のバッファを確保 (`newtok(p);`)
2. バッファに読み込んだ数値を書き込み (`tokadd(p, c);`)
3. バッファを0埋め (`tokfix(p);`)
4. バッファからトークンを読み込み (`tok(p);`)
