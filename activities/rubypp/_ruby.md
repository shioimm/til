# Ruby
#### tokenの定義 (L1301)

```c
%token tUPLUS  RUBY_TOKEN(UPLUS)  "unary+"
```

#### Lexer Buffer (`p = struct parser_params *p`) の構造 (L261)

```c
//  lex.pbeg     lex.ptok     lex.pcur     lex.pend
//     |            |            |            |
//     |------------+------------+------------|
//                  |<---------->|
//                      token

struct parser_params {
  // ...

  YYSTYPE *lval;

  struct {
    // ...
    const char *pbeg;
    const char *pcur;
    const char *pend;
    const char *ptok;
    // ...
  }
  // ...
}
```

#### yylvalの定義 (L5912)

```c
#define yylval  (*p->lval) (parser_params構造体のメンバYYSTYPE *lval)
```

#### `SET_LEX_STATE`マクロ

```c
# define SET_LEX_STATE(ls) parser_set_lex_state(p, ls, __LINE__)

// struct parser_params p->lex.state = ls (L10901)
```

#### `IS_BEG`マクロ

```c
#define IS_lex_state_for(x, ls)     ((x) & (ls))
#define IS_lex_state_all_for(x, ls) (((x) & (ls)) == (ls))
#define IS_lex_state(ls)            IS_lex_state_for(p->lex.state, (ls))
#define IS_lex_state_all(ls)        IS_lex_state_all_for(p->lex.state, (ls))

// lex_stateがEXPR_BEG_ANY
// もしくはEXPR_ARG|EXPR_LABELED
#define IS_BEG() (IS_lex_state(EXPR_BEG_ANY) || IS_lex_state_all(EXPR_ARG|EXPR_LABELED))
```

#### `yylex()` (L9813)

```c
case '+':
  c = nextc(p);

  // lex_stateがEXPR_FNAMEもしくはEXPR_DOT (L7569)
  // (def +が再定義された場合、もしくは<Receiver>.+が実行された場合)
  if (IS_AFTER_OPERATOR()) {
    SET_LEX_STATE(EXPR_ARG);
    if (c == '@') {
      return tUPLUS; // トークンtUPLUSをパーサに渡す
    }
    pushback(p, c); // p->lex.pcur-- (L6799)
    return '+'; // トークン'+'をパーサに渡す
  }

  // <Receiver>+= が実行された場合
  if (c == '=') {
    set_yylval_id('+'); // define set_yylval_id(x)  (yylval.id = (x)) (L5947)
    SET_LEX_STATE(EXPR_BEG);
    return tOP_ASGN; // トークンtOP_ASGNをパーサに渡す
  }

  // 通常はIS_BEGがtrueになっていそう
  if (IS_BEG() || (IS_SPCARG(c) && arg_ambiguous(p, '+'))) {
    SET_LEX_STATE(EXPR_BEG);
    pushback(p, c);
    if (c != -1 && ISDIGIT(c)) {
      return parse_numeric(p, '+');
    }
    return tUPLUS; // トークンtUPLUSをパーサに渡す
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

#### `method_call`

```c
// method_call : primary_value call_op operation2 opt_paren_args
// {
//   $$ = new_qcall(p, $2, $1, $3, $4, &@3, &@$); // 構文木に新しいノードを追加する
//   nd_set_line($$, @3.end_pos.lineno);          // 行番号のセット
// }
//
// primary_value  = primary
// call_op        = '.' / tANDDOT
// operation2     = operation (tIDENTIFIER / tCONSTANT / tFID) / op (演算子)
// opt_paren_args = none / paren_args


// new_qcall(): L10517
static NODE *
new_qcall(struct parser_params* p,
          ID atype,
          NODE *recv,
          ID mid,
          NODE *args,
          const YYLTYPE *op_loc,
          const YYLTYPE *loc)
{
  NODE *qcall = NEW_QCALL(atype, recv, mid, args, loc); // 新しいノード (NODE_QCALL or NODE_CALL) を追加する
  nd_set_line(qcall, op_loc->beg_pos.lineno);
  return qcall;
}

// NEW_QCALL: L477
#define NEW_QCALL(q,r,m,a,loc) NEW_NODE(NODE_CALL_Q(q),r,m,a,loc)

// NODE_CALL_Q: L476 (NODE_QCALL = "safe method invocation" / NODE_CALL = "method invocation")
#define NODE_CALL_Q(q) (CALL_Q_P(q) ? NODE_QCALL : NODE_CALL)

// nd_set_line: node.h L204
#define nd_set_line(n,l) (n)->flags=(((n)->flags&~((VALUE)(-1)<<NODE_LSHIFT))|((VALUE)((l)&NODE_LMASK)<<NODE_LSHIFT))
```

#### `command_asgn`

```c
// command_asgn : var_lhs tOP_ASGN lex_ctxt command_rhs
// {
//   $$ = new_op_assign(p, $1, $2, $4, $3, &@$);
// }
//
// var_lhs      = user_variable (tIDENTIFIER / tCONSTANT / nonlocal_var)
// lex_ctxt     = none (p->ctxt)
// command_rhs  = command_call %prec tOP_ASGN { value_expr($1); $$ = $1; }
// command_call = command
// command      = fcall command_args { $1->nd_args = $2; ... $$ = $1; }
// fcall        = operation (tIDENTIFIER / tCONSTANT / tFID) { $$ = NEW_FCALL($1, 0, &@$); }

// value_expr: L552
#define value_expr(node) value_expr_gen(p, (node))

// value_expr_gen: L11715
static int
value_expr_gen(struct parser_params *p, NODE *node)
{
  NODE *void_node = value_expr_check(p, node);
  if (void_node) {
    yyerror1(&void_node->nd_loc, "void value expression");
    /* or "control never reach"? */
    return FALSE;
  }
  return TRUE;
}

// NEW_FCALL: node.h L359
#define NEW_FCALL(m,a,loc) NEW_NODE(NODE_FCALL,0,m,a,loc)

// new_op_assign: L12578
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

// NEW_CALL: L357
#define NEW_CALL(r,m,a,loc) NEW_NODE(NODE_CALL,r,m,a,loc)

// gettable: L10625
static NODE*
gettable(struct parser_params *p, ID id, const YYLTYPE *loc)
{
  ID *vidp = NULL;
  NODE *node;
  // ...
  switch (id_type(id)) {
    case ID_LOCAL:
      if (dyna_in_block(p) && dvar_defined_ref(p, id, &vidp)) {
        if (NUMPARAM_ID_P(id) && numparam_nested_p(p)) return 0;
        if (id == p->cur_arg) {
                compile_error(p, "circular argument reference - %"PRIsWARN, rb_id2str(id));
                return 0;
        }
        if (vidp) *vidp |= LVAR_USED;
        node = NEW_DVAR(id, loc);
        return node;
      }
      if (local_id_ref(p, id, &vidp)) {
        if (id == p->cur_arg) {
          compile_error(p, "circular argument reference - %"PRIsWARN, rb_id2str(id));
          return 0;
        }
        if (vidp) *vidp |= LVAR_USED;
        node = NEW_LVAR(id, loc);
        return node;
      }
      if (dyna_in_block(p) && NUMPARAM_ID_P(id) && parser_numbered_param(p, NUMPARAM_ID_TO_IDX(id))) {
        if (numparam_nested_p(p)) return 0;
        node = NEW_DVAR(id, loc);
        struct local_vars *local = p->lvtbl;
        if (!local->numparam.current) local->numparam.current = node;
        return node;
      }
      // ...
      /* method call without arguments */
      return NEW_VCALL(id, loc);
    case ID_GLOBAL:
      return NEW_GVAR(id, loc);
    case ID_INSTANCE:
      return NEW_IVAR(id, loc);
    case ID_CONST:
      return NEW_CONST(id, loc);
    case ID_CLASS:
      return NEW_CVAR(id, loc);
  }
  compile_error(p, "identifier %"PRIsVALUE" is not valid to get", rb_id2str(id));
  return 0;
}

// NEW_LIST: node.h L323
// #define NEW_LIST(a,loc) NEW_NODE(NODE_LIST,a,1,0,loc)
```

#### `NEW_NODE`

```c
// NEW_NODE: node.h L293
#define NEW_NODE(t,a0,a1,a2,loc) rb_node_newnode((t),(VALUE)(a0),(VALUE)(a1),(VALUE)(a2),loc) (node.h)

// rb_node_newnode: L511
#define rb_node_newnode(type, a1, a2, a3, loc) node_newnode(p, (type), (a1), (a2), (a3), (loc))

// node_newnode(): L12835
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
