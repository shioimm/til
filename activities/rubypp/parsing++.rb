i = 0
i++

# $ ./miniruby -y ../ruby/test.rb
#
# Starting parse
# Entering state 0
# Stack now 0
# Reducing stack by rule 1 (line 1391):
# lex_state: NONE -> BEG at line 1392
# vtable_alloc:12793: 0x00006000036b7940
# vtable_alloc:12794: 0x00006000036b7960
# cmdarg_stack(push): 0 at line 12807
# cond_stack(push): 0 at line 12808
# -> $$ = nterm $@1 (1.0-1.0: )
# Entering state 2
# Stack now 0 2
# Reading a token
# lex_state: BEG -> CMDARG at line 9429
# Next token is token "local variable or method" (1.0-1.1: i)
# Shifting token "local variable or method" (1.0-1.1: i)
# Entering state 35
# Stack now 0 2 35
# Reading a token
# lex_state: CMDARG -> BEG at line 9680
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 653 (line 5215):
#    $1 = token "local variable or method" (1.0-1.1: i)
# -> $$ = nterm user_variable (1.0-1.1: )
# Entering state 122
# Stack now 0 2 122
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 121 (line 2256):
#    $1 = nterm user_variable (1.0-1.1: )
# vtable_add:12894: p->lvtbl->vars(0x00006000036b7960), i
# -> $$ = nterm lhs (1.0-1.1: NODE_LASGN)
# Entering state 87
# Stack now 0 2 87
# Next token is token '=' (1.2-1.3: )
# Shifting token '=' (1.2-1.3: )
# Entering state 343
# Stack now 0 2 87 343
# Reducing stack by rule 782 (line 5936):
# -> $$ = nterm none (1.3-1.3: )
# Entering state 431
# Stack now 0 2 87 343 431
# Reducing stack by rule 271 (line 2761):
#    $1 = nterm none (1.3-1.3: )
# -> $$ = nterm lex_ctxt (1.3-1.3: )
# Entering state 583
# Stack now 0 2 87 343 583
# Reading a token
# lex_state: BEG -> END at line 8701
# lex_state: END -> END at line 7995
# Next token is token "integer literal" (1.4-1.5: 1)
# Shifting token "integer literal" (1.4-1.5: 1)
# Entering state 41
# Stack now 0 2 87 343 583 41
# Reducing stack by rule 646 (line 5204):
#    $1 = token "integer literal" (1.4-1.5: 1)
# -> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)
# Entering state 120
# Stack now 0 2 87 343 583 120
# Reducing stack by rule 644 (line 5193):
#    $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm numeric (1.4-1.5: NODE_LIT)
# Entering state 119
# Stack now 0 2 87 343 583 119
# Reducing stack by rule 596 (line 4819):
#    $1 = nterm numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm literal (1.4-1.5: NODE_LIT)
# Entering state 106
# Stack now 0 2 87 343 583 106
# Reducing stack by rule 311 (line 3050):
#    $1 = nterm literal (1.4-1.5: NODE_LIT)
# -> $$ = nterm primary (1.4-1.5: NODE_LIT)
# Entering state 90
# Stack now 0 2 87 343 583 90
# Reading a token
# lex_state: END -> BEG at line 9587
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 264 (line 2738):
#    $1 = nterm primary (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.4-1.5: NODE_LIT)
# Entering state 774
# Stack now 0 2 87 343 583 774
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 277 (line 2795):
#    $1 = nterm arg (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)
# Entering state 776
# Stack now 0 2 87 343 583 776
# Reducing stack by rule 216 (line 2440):
#    $1 = nterm lhs (1.0-1.1: NODE_LASGN)
#    $2 = token '=' (1.2-1.3: )
#    $3 = nterm lex_ctxt (1.3-1.3: )
#    $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.0-1.5: NODE_LASGN)
# Entering state 88
# Stack now 0 2 88
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 65 (line 1862):
#    $1 = nterm arg (1.0-1.5: NODE_LASGN)
# -> $$ = nterm expr (1.0-1.5: NODE_LASGN)
# Entering state 75
# Stack now 0 2 75
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 37 (line 1664):
#    $1 = nterm expr (1.0-1.5: NODE_LASGN)
# -> $$ = nterm stmt (1.0-1.5: NODE_LASGN)
# Entering state 73
# Stack now 0 2 73
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 7 (line 1446):
#    $1 = nterm stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)
# Entering state 72
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1430):
#    $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (1.5-1.5: )
# Shifting token '\n' (1.5-1.5: )
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 779 (line 5928):
#    $1 = token '\n' (1.5-1.5: )
# -> $$ = nterm term (1.5-1.5: )
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 780 (line 5931):
#    $1 = nterm term (1.5-1.5: )
# -> $$ = nterm terms (1.5-1.5: )
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# lex_state: BEG -> CMDARG at line 9429
# lex_state: CMDARG -> END|LABEL at line 9447
# Next token is token "local variable or method" (2.0-2.1: i)
# Shifting token "local variable or method" (2.0-2.1: i)
# Entering state 35
# Stack now 0 2 71 313 35
# Reading a token
# lex_state: END|LABEL -> BEG at line 9857
# Next token is token "incremental-operator-assignment" (2.1-2.3: )
# Reducing stack by rule 653 (line 5215):
#    $1 = token "local variable or method" (2.0-2.1: i)
# -> $$ = nterm user_variable (2.0-2.1: )
# Entering state 122
# Stack now 0 2 71 313 122
# Next token is token "incremental-operator-assignment" (2.1-2.3: )
# Reducing stack by rule 665 (line 5251):
#    $1 = nterm user_variable (2.0-2.1: )
# -> $$ = nterm var_lhs (2.0-2.1: NODE_LASGN)
# Entering state 125
# Stack now 0 2 71 313 125
# Next token is token "incremental-operator-assignment" (2.1-2.3: )
# Reducing stack by rule 782 (line 5936):
# -> $$ = nterm none (2.1-2.1: )
# Entering state 431
# Stack now 0 2 71 313 125 431
# Reducing stack by rule 271 (line 2761):
#    $1 = nterm none (2.1-2.1: )
# -> $$ = nterm lex_ctxt (2.1-2.1: )
# Entering state 430
# Stack now 0 2 71 313 125 430
# Next token is token "incremental-operator-assignment" (2.1-2.3: )
# Shifting token "incremental-operator-assignment" (2.1-2.3: )
# Entering state 660
# Stack now 0 2 71 313 125 430 660
# Reducing stack by rule 218 (line 2454):
#    $1 = nterm var_lhs (2.0-2.1: NODE_LASGN)
#    $2 = nterm lex_ctxt (2.1-2.1: )
#    $3 = token "incremental-operator-assignment" (2.1-2.3: )
# lex_state: BEG -> END at line 2471
# -> $$ = nterm arg (2.0-2.3: NODE_LASGN)
# Entering state 88
# Stack now 0 2 71 313 88
# Reading a token
# lex_state: END -> BEG at line 9587
# Next token is token '\n' (2.3-2.3: )
# Reducing stack by rule 65 (line 1862):
#    $1 = nterm arg (2.0-2.3: NODE_LASGN)
# -> $$ = nterm expr (2.0-2.3: NODE_LASGN)
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (2.3-2.3: )
# Reducing stack by rule 37 (line 1664):
#    $1 = nterm expr (2.0-2.3: NODE_LASGN)
# -> $$ = nterm stmt (2.0-2.3: NODE_LASGN)
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (2.3-2.3: )
# Reducing stack by rule 7 (line 1446):
#    $1 = nterm stmt (2.0-2.3: NODE_LASGN)
# -> $$ = nterm top_stmt (2.0-2.3: NODE_LASGN)
# Entering state 522
# Stack now 0 2 71 313 522
# Reducing stack by rule 6 (line 1437):
#    $1 = nterm top_stmts (1.0-1.5: NODE_LASGN)
#    $2 = nterm terms (1.5-1.5: )
#    $3 = nterm top_stmt (2.0-2.3: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-2.3: NODE_BLOCK)
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (2.3-2.3: )
# Shifting token '\n' (2.3-2.3: )
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 779 (line 5928):
#    $1 = token '\n' (2.3-2.3: )
# -> $$ = nterm term (2.3-2.3: )
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 780 (line 5931):
#    $1 = nterm term (2.3-2.3: )
# -> $$ = nterm terms (2.3-2.3: )
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# Now at end of input.
# Reducing stack by rule 770 (line 5907):
#    $1 = nterm terms (2.3-2.3: )
# -> $$ = nterm opt_terms (2.3-2.3: )
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1417):
#    $1 = nterm top_stmts (1.0-2.3: NODE_BLOCK)
#    $2 = nterm opt_terms (2.3-2.3: )
# -> $$ = nterm top_compstmt (1.0-2.3: NODE_BLOCK)
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1391):
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-2.3: NODE_BLOCK)
# vtable_free:12827: p->lvtbl->args(0x00006000036b7940)
# vtable_free:12828: p->lvtbl->vars(0x00006000036b7960)
# cmdarg_stack(pop): 0 at line 12829
# cond_stack(pop): 0 at line 12830
# -> $$ = nterm program (1.0-2.3: )
# Entering state 1
# Stack now 0 1
# Now at end of input.
# Shifting token "end-of-input" (2.3-2.3: )
# Entering state 3
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (2.3-2.3: )
# Cleanup: popping nterm program (1.0-2.3: )
