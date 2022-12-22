# Ripper

```c
// 成功ケース
arg : var_lhs tOP_ASGN lex_ctxt arg_rhs
    {
    /*%%%*/
    $$ = new_op_assign(p, $1, $2, $4, $3, &@$);
    /*% %*/
    /*% ripper: opassign!($1, $2, $4) %*/
    }
```

```c
// 失敗ケース
arg : var_lhs lex_ctxt tINCOP_ASGN
    {
    VALUE v = rb_cstr_to_inum("1", 16, FALSE);

    NODE *x = NEW_LIT(v, &NULL_LOC);
    YYLTYPE _cur_loc;
    rb_parser_set_location(p, &_cur_loc);
    yylval.node = (x);

    RB_OBJ_WRITTEN(p->ast, Qnil, x);

    SET_LEX_STATE(EXPR_END);

    /*%%%*/
    $$ = new_op_assign(p, $1, $3, x, $2, &@$);
    /*% %*/
    /*% ripper: opassign!($1, $3, v) %*/
    }

// compiling ripper.c
// build/ext/ripper/ripper.y:2476:64:
// error: called object type 'NODE *' (aka 'struct RNode *') is not a function or function pointer
// {
//   VALUE v1,v2,v3,v4;
//   v1=(yyvsp[-2].val);
//   v2=(yyvsp[0].val);
//   v3=x(); <------------ (called object type 'NODE *' is not a function or function pointer)
//   v4=dispatch3(opassign,v1,v2,v3);
//   (yyval.val)=v4;
//  }
```

### `parse.y`

```c
// VALUE x = rb_cstr_to_inum("1", 16, FALSE);
# define set_yylval_literal(x) add_mark_object(p, (x))

static inline VALUE
add_mark_object(struct parser_params *p, VALUE obj)
{
  if (!SPECIAL_CONST_P(obj) && !RB_TYPE_P(obj, T_NODE)) {
    rb_ast_add_mark_object(p->ast, obj);
  }
  return obj;
}

# define set_yylval_node(x) \
  (yylval.val = ripper_new_yylval(p, 0, 0, STR_NEW(p->lex.ptok, p->lex.pcur-p->lex.ptok)))

// ptr = p->lex.ptok
// len = p->lex.pcur-p->lex.ptok)
#define STR_NEW(ptr,len) rb_enc_str_new((ptr),(len),p->enc)

// string.c
VALUE
rb_enc_str_new(const char *ptr, long len, rb_encoding *enc)
{
  VALUE str;

  if (!enc) return rb_str_new(ptr, len);

  str = str_new0(rb_cString, ptr, len, rb_enc_mbminlen(enc));
  rb_enc_associate(str, enc);
  return str;
}

// a = 0
// b = 0
// c = VALUE str
static inline VALUE
ripper_new_yylval(struct parser_params *p, ID a, VALUE b, VALUE c)
{
  if (ripper_is_node_yylval(c)) c = RNODE(c)->nd_cval;
  add_mark_object(p, b);
  add_mark_object(p, c);
  return NEW_RIPPER(a, b, c, &NULL_LOC);
}
```

### `build/ext/ripper/ripper.y`

```c
// n = opassign
// a = var_lhs
// b = tINCOP_ASGN
// c = struct RNode *

#define dispatch3(n,a,b,c)  ripper_dispatch3(p, TOKEN_PASTE(ripper_id_, n), (a), (b), (c))

// version.h
#define TOKEN_PASTE(x,y) x##y

static VALUE
ripper_dispatch3(struct parser_params *p, ID mid, VALUE a, VALUE b, VALUE c)
{
  validate(a);
  validate(b);
  validate(c);
  return rb_funcall(p->value, mid, 3, a, b, c);
}

// vm_eval.c
VALUE
rb_funcall(VALUE recv, ID mid, int n, ...)
{
  VALUE *argv;
  va_list ar;

  if (n > 0) {
    long i;

    va_start(ar, n);

    argv = ALLOCA_N(VALUE, n);

    for (i = 0; i < n; i++) {
      argv[i] = va_arg(ar, VALUE);
    }
    va_end(ar);
  } else {
    argv = 0;
  }
  return rb_funcallv(recv, mid, n, argv);
}
```
