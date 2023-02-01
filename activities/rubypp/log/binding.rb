binding

# add_delayed_token:7062 (0: 0|0|0)
# Starting parse
# Entering state 0
#
# Stack now 0
# Reducing stack by rule 1 (line 1580):
# lex_state: NONE -> BEG at line 1581
# vtable_alloc:13130: 0x00006000029d5440
# vtable_alloc:13131: 0x00006000029d5460
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm $@1 (1.0-1.0: )
#
# Entering state 2
# Stack now 0 2
# Reading a token
# lex_state: BEG -> CMDARG at line 9733
# parser_dispatch_scan_event:10499 (1: 0|7|1)
# Next token is token "local variable or method" (1.0-1.7: binding)
# Shifting token "local variable or method" (1.0-1.7: binding)
#
# Entering state 35
# Stack now 0 2 35
# Reading a token
# add_delayed_token:7062 (1: 7|1|0)
# lex_state: CMDARG -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (1: 8|0|0)
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (1.0-1.7: binding)
# -> $$ = nterm user_variable (1.0-1.7: )
#
# Entering state 122
# Stack now 0 2 122
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 662 (line 5408):
#    $1 = nterm user_variable (1.0-1.7: )
# -> $$ = nterm var_ref (1.0-1.7: NODE_VCALL)
#
# -----------------------------------------------------
#
# [node.h]
# #define NEW_VCALL(m,loc) NEW_NODE(NODE_VCALL,0,m,0,loc)
# #define NEW_NODE(t,a0,a1,a2,loc) rb_node_newnode((t),(VALUE)(a0),(VALUE)(a1),(VALUE)(a2),loc)
#
# [parse.y]
# #define rb_node_newnode(type, a1, a2, a3, loc) node_newnode(p, (type), (a1), (a2), (a3), (loc))
#
# static NODE*
# node_newnode(
#   struct parser_params *p,
#   enum node_type type,          // NODE_VCALL
#   VALUE a0,                     // 0
#   VALUE a1,                     // VALUE
#   VALUE a2,                     // 0
#   const rb_code_location_t *loc // &@$
# )
# {
#   NODE *n = rb_ast_newnode(p->ast, type);
#   rb_node_init(n, type, a0, a1, a2);
#   nd_set_loc(n, loc);
#   nd_set_node_id(n, parser_get_node_id(p));
#   return n;
# }
#
# static int
# parser_get_node_id(struct parser_params *p)
# {
#   int node_id = p->node_id;
#   p->node_id++;
#   return node_id;
# }
#
# -----------------------------------------------------
#
# Entering state 124
# Stack now 0 2 124
# Reducing stack by rule 318 (line 3228):
#    $1 = nterm var_ref (1.0-1.7: NODE_VCALL)
# -> $$ = nterm primary (1.0-1.7: NODE_VCALL)
#
# Entering state 90
# Stack now 0 2 90
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (1.0-1.7: NODE_VCALL)
# -> $$ = nterm arg (1.0-1.7: NODE_VCALL)
#
# Entering state 88
# Stack now 0 2 88
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (1.0-1.7: NODE_VCALL)
# -> $$ = nterm expr (1.0-1.7: NODE_VCALL)
#
# Entering state 75
# Stack now 0 2 75
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (1.0-1.7: NODE_VCALL)
# -> $$ = nterm stmt (1.0-1.7: NODE_VCALL)
#
# Entering state 73
# Stack now 0 2 73
# Next token is token '\n' (1.7-1.8: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (1.0-1.7: NODE_VCALL)
# -> $$ = nterm top_stmt (1.0-1.7: NODE_VCALL)
#
# Entering state 72
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1619):
#    $1 = nterm top_stmt (1.0-1.7: NODE_VCALL)
# -> $$ = nterm top_stmts (1.0-1.7: NODE_VCALL)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (1.7-1.8: )
# Shifting token '\n' (1.7-1.8: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (1.7-1.8: )
# -> $$ = nterm term (1.7-1.7: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (1.7-1.7: )
# -> $$ = nterm terms (1.7-1.7: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# add_delayed_token:7062 (1: 8|0|0)
# parser_dispatch_scan_event:10499 (2: 0|1|7)
# Now at end of input.
# Reducing stack by rule 769 (line 6094):
#    $1 = nterm terms (1.7-1.7: )
# -> $$ = nterm opt_terms (1.7-1.7: )
#
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1606):
#    $1 = nterm top_stmts (1.0-1.7: NODE_VCALL)
#    $2 = nterm opt_terms (1.7-1.7: )
# -> $$ = nterm top_compstmt (1.0-1.7: NODE_VCALL)
#
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1580):
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-1.7: NODE_VCALL)
# vtable_free:13164: p->lvtbl->args(0x00006000029d5440)
# vtable_free:13165: p->lvtbl->vars(0x00006000029d5460)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm program (1.0-1.7: )
#
# Entering state 1
# Stack now 0 1
# Now at end of input.
# Shifting token "end-of-input" (2.0-2.1: )
#
# Entering state 3
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (2.0-2.1: )
# Cleanup: popping nterm program (1.0-1.7: )
# Syntax OK
