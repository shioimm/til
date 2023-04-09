# パーサ

```c
// arg : var_lhs tOP_ASGN lex_ctxt arg_rhs
// {
//   $$ = new_op_assign(p, $1, $2, $4, $3, &@$);
// }
//
// var_lhs        : user_variable { $$ = assignable(p, $1, 0, &@$); }
// user_variable  : tIDENTIFIER
// tOP_ASGN       : '+='
// lex_ctxt       : none { $$ = p->ctxt; }
// arg_rhs        : arg %prec tOP_ASGN { value_expr($1); $$ = $1; }
// arg            : primary { $$ = $1; }
// primary        : literal
// literal        : numeric
// numeric        : simple_numeric { $$ = $2; RB_OBJ_WRITE(p->ast, &$$->nd_lit, negate_lit(p, $$->nd_lit)); }
// simple_numeric : tINTEGER
```

```c
// new_op_assign()
static NODE *
new_op_assign(
  struct parser_params *p,
  NODE *lhs,               // 左辺
  ID op,                   // 演算子
  NODE *rhs,               // 右辺
  struct lex_context ctxt, // Ractor対応
  const YYLTYPE *loc)
{
  NODE *asgn;

  if (lhs) {
    ID vid = lhs->nd_vid;
    YYLTYPE lhs_loc = lhs->nd_loc;
    int shareable = ctxt.shareable_constant_value;
    if (shareable) {
      // ...
    }
    // ...

    if (op == tOROP) {
      // ...
    } else if (op == tANDOP) {
      // ...
    } else {
      asgn = lhs;
      // 右辺を計算するノードを作成
      rhs = NEW_CALL(gettable(p, vid, &lhs_loc), op, NEW_LIST(rhs, &rhs->nd_loc), loc);
      if (shareable) {
        rhs = shareable_constant_value(p, shareable, lhs, rhs, &rhs->nd_loc);
      }
      // 左辺に代入する値として右辺を計算するノードをセットする
      asgn->nd_value = rhs;
      nd_set_loc(asgn, loc);
    }
  } else {
    // ...
  }
  return asgn;
}

// NEW_CALL
#define NEW_CALL(r,m,a,loc) NEW_NODE(NODE_CALL,r,m,a,loc)

// NEW_LIST: node.h
// #define NEW_LIST(a,loc) NEW_NODE(NODE_LIST,a,1,0,loc)

// NEW_NODE: node.h
#define NEW_NODE(t,a0,a1,a2,loc) rb_node_newnode((t),(VALUE)(a0),(VALUE)(a1),(VALUE)(a2),loc) (node.h)

// rb_node_newnode
#define rb_node_newnode(type, a1, a2, a3, loc) node_newnode(p, (type), (a1), (a2), (a3), (loc))

// node_newnode():
static NODE*
node_newnode(struct parser_params *p,
             enum node_type type,
             VALUE a0,
             VALUE a1,
             VALUE a2,
             const rb_code_location_t *loc)
{
  NODE *n = rb_ast_newnode(p->ast, type);

  rb_node_init(n, type, a0, a1, a2);

  nd_set_loc(n, loc);
  nd_set_node_id(n, parser_get_node_id(p));
  return n;
}
```

- https://github.com/ruby/ruby/blob/master/parse.y
