# 数値1のスキャン
- `parse_numeric()`
- `set_integer_literal()`
- `set_number_literal()`
  - `set_yylval_literal()`
    - `set_yylval_node()`
    - `RB_OBJ_WRITTEN()`

#### `parse_numeric()`

```c
static enum yytokentype
parse_numeric(struct parser_params *p, int c)
{
  // SET_LEX_STATE(EXPR_END);
  // newtok(p);
  // if (c == '0') -> true
  //   if (c == 'x' || c == 'X') -> true (hexadecimal)
  //     if (c != -1 && ISXDIGIT(c)) -> true
  //       while ((c = nextc(p)) != -1)
  //         if (!ISXDIGIT(c)) でbreak
  //
  //   return set_integer_literal(p, rb_cstr_to_inum(tok(p), 16, FALSE), suffix);`
  //     (tok(p) - 10ffff (16進数))
  //     (suffix - 0)
}
```

#### `set_integer_literal()`

```c
static enum yytokentype
set_integer_literal(struct parser_params *p, VALUE v, int suffix)
{
  // enum yytokentype type = tINTEGER;
  // return set_number_literal(p, v, type, suffix);
  //   (v = rb_cstr_to_inum(tok(p), 16, FALSE); の返り値)
  //   (suffix = 0)

}
```

#### `set_number_literal()`

```c
static enum yytokentype
set_number_literal(struct parser_params *p, VALUE v,enum yytokentype type, int suffix)
{
  // set_yylval_literal(v); // (v = rb_cstr_to_inum(tok(p), 16, FALSE); の返り値)
  // SET_LEX_STATE(EXPR_END);
  // return type;
}
```

#### `set_yylval_literal()`

```c
// (x = rb_cstr_to_inum(tok(p), 16, FALSE); の返り値)

# define set_yylval_literal(x)
do {
  set_yylval_node(NEW_LIT(x, &_cur_loc)); // NEW_LIT = NODE*
  RB_OBJ_WRITTEN(p->ast, Qnil, x);
} while(0)
```

#### `NEW_LIT`

```c
// node.h
// (l = rb_cstr_to_inum(tok(p), 16, FALSE);)
// (loc = &_cur_loc)
#define NEW_LIT(l,loc) NEW_NODE(NODE_LIT,l,0,0,loc)

// node.h
// (t = NODE_LIT (enum node_typeのひとつ))
// (a0 = rb_cstr_to_inum(tok(p), 16, FALSE);)
// (a1 = 0)
// (a2 = 0)
// (loc = &_cur_loc)
#define NEW_NODE(t,a0,a1,a2,loc) rb_node_newnode((t),(VALUE)(a0),(VALUE)(a1),(VALUE)(a2),loc)

// parse.y
// (type = NODE_LIT)
// (a1 = (VALUE)rb_cstr_to_inum(tok(p), 16, FALSE);)
// (a2 = (VALUE)0)
// (a3 = (VALUE)0)
// (loc = &_cur_loc)
#define rb_node_newnode(type, a1, a2, a3, loc) node_newnode(p, (type), (a1), (a2), (a3), (loc))

static NODE*
node_newnode(
  struct parser_params *p,
  enum node_type type, // NODE_LIT
  VALUE a0,            // (VALUE)rb_cstr_to_inum(tok(p), 16, FALSE);
  VALUE a1,            // (VALUE)0
  VALUE a2,            // (VALUE)0
  const rb_code_location_t *loc)
{
  NODE *n = rb_ast_newnode(p->ast, type);
  rb_node_init(n, type, a0, a1, a2);
  nd_set_loc(n, loc);
  nd_set_node_id(n, parser_get_node_id(p));
  return n; // NODE *n = rb_ast_newnode(p->ast, type); を返す
}
```

#### `set_yylval_node()`
WIP

#### `RB_OBJ_WRITTEN` (include/ruby/internal/rgengc.h)
WIP

- https://github.com/ruby/ruby/blob/master/parse.y
