i = 1
i += 1

# $ ruby -y parsing+=.rb
#
# Starting parse
#
# ---------------------- L1 -----------------------
#
# Entering state 0
# Reducing stack by rule 1 (line 1327):
# lex_state: NONE -> BEG at line 1328
# vtable_alloc:12570: 0x0000600003376ee0
# vtable_alloc:12571: 0x0000600003376f00
# cmdarg_stack(push): 0 at line 12584
# cond_stack(push): 0 at line 12585
# -> $$ = nterm $@1 (1.0-1.0: )
# Stack now 0
# Entering state 2
# Reading a token:
# lex_state: BEG -> CMDARG at line 9214
# Next token is token "local variable or method" (1.0-1.1: i)
# Shifting token "local variable or method" (1.0-1.1: i)
# Entering state 35
# Reading a token:
# lex_state: CMDARG -> BEG at line 9458
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 649 (line 5059):
#    $1 = token "local variable or method" (1.0-1.1: i)
# -> $$ = nterm user_variable (1.0-1.1: )
# Stack now 0 2
# Entering state 121
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 119 (line 2180):
#    $1 = nterm user_variable (1.0-1.1: )
# vtable_add:12671: p->lvtbl->vars(0x0000600003376f00), i
# -> $$ = nterm lhs (1.0-1.1: )
# Stack now 0 2
# Entering state 87
# Next token is token '=' (1.2-1.3: )
# Shifting token '=' (1.2-1.3: )
# Entering state 346
# Reading a token:
# lex_state: BEG -> END at line 8514
# lex_state: END -> END at line 7813
# Next token is token "integer literal" (1.4-1.5: 1)
# Reducing stack by rule 782 (line 5774):
# -> $$ = nterm none (1.3-1.3: )
# Stack now 0 2 87 346
# Entering state 581
# Reducing stack by rule 269 (line 2668):
#    $1 = nterm none (1.3-1.3: )
# -> $$ = nterm lex_ctxt (1.3-1.3: )
# Stack now 0 2 87 346
# Entering state 586
# Next token is token "integer literal" (1.4-1.5: 1)
# Shifting token "integer literal" (1.4-1.5: 1)
# Entering state 41
# Reducing stack by rule 642 (line 5048):
#    $1 = token "integer literal" (1.4-1.5: 1)
# -> $$ = nterm simple_numeric (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 120
# Reducing stack by rule 640 (line 5037):
#    $1 = nterm simple_numeric (1.4-1.5: )
# -> $$ = nterm numeric (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 119
# Reducing stack by rule 590 (line 4661):
#    $1 = nterm numeric (1.4-1.5: )
# -> $$ = nterm literal (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 106
# Reducing stack by rule 307 (line 2938):
#    $1 = nterm literal (1.4-1.5: )
# -> $$ = nterm primary (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 90
# Reading a token:
# lex_state: END -> BEG at line 9365
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 261 (line 2641):
#    $1 = nterm primary (1.4-1.5: )
# -> $$ = nterm arg (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 777
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 275 (line 2702):
#    $1 = nterm arg (1.4-1.5: )
# -> $$ = nterm arg_rhs (1.4-1.5: )
# Stack now 0 2 87 346 586
# Entering state 779
# Reducing stack by rule 214 (line 2364):
#    $1 = nterm lhs (1.0-1.1: )
#    $2 = token '=' (1.2-1.3: )
#    $3 = nterm lex_ctxt (1.3-1.3: )
#    $4 = nterm arg_rhs (1.4-1.5: )
# -> $$ = nterm arg (1.0-1.5: )
# Stack now 0 2
# Entering state 88
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 64 (line 1792):
#    $1 = nterm arg (1.0-1.5: )
# -> $$ = nterm expr (1.0-1.5: )
# Stack now 0 2
# Entering state 75
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 39 (line 1608):
#    $1 = nterm expr (1.0-1.5: )
# -> $$ = nterm stmt (1.0-1.5: )
# Stack now 0 2
# Entering state 73
# Next token is token '\n' (1.5-1.5: )
# Reducing stack by rule 8 (line 1386):
#    $1 = nterm stmt (1.0-1.5: )
# -> $$ = nterm top_stmt (1.0-1.5: )
# Stack now 0 2
# Entering state 72
# Reducing stack by rule 5 (line 1366):
#    $1 = nterm top_stmt (1.0-1.5: )
# -> $$ = nterm top_stmts (1.0-1.5: )
# Stack now 0 2
# Entering state 71
# Next token is token '\n' (1.5-1.5: )
# Shifting token '\n' (1.5-1.5: )
# Entering state 313
# Reducing stack by rule 779 (line 5766):
#    $1 = token '\n' (1.5-1.5: )
# -> $$ = nterm term (1.5-1.5: )
# Stack now 0 2 71
# Entering state 315
# Reducing stack by rule 780 (line 5769):
#    $1 = nterm term (1.5-1.5: )
# -> $$ = nterm terms (1.5-1.5: )
# Stack now 0 2 71
#
# ---------------------- L2 -----------------------
#
# Entering state 316
# Reading a token:
# lex_state: BEG -> CMDARG at line 9214
# lex_state: CMDARG -> END|LABEL at line 9232
# Next token is token "local variable or method" (2.0-2.1: i)
# Shifting token "local variable or method" (2.0-2.1: i)
# Entering state 35
# Reading a token:
# lex_state: END|LABEL -> BEG at line 9635
# Next token is token "operator-assignment" (2.2-2.4: +)
# Reducing stack by rule 649 (line 5059):
#    $1 = token "local variable or method" (2.0-2.1: i)
# -> $$ = nterm user_variable (2.0-2.1: )
# Stack now 0 2 71 316
# Entering state 121
# Next token is token "operator-assignment" (2.2-2.4: +)
# Reducing stack by rule 663 (line 5097):
#    $1 = nterm user_variable (2.0-2.1: )
# -> $$ = nterm var_lhs (2.0-2.1: )
# Stack now 0 2 71 316
# Entering state 124
# Next token is token "operator-assignment" (2.2-2.4: +)
# Shifting token "operator-assignment" (2.2-2.4: +)
# Entering state 431
# Reading a token:
# lex_state: BEG -> END at line 8514
# lex_state: END -> END at line 7813
# Next token is token "integer literal" (2.5-2.6: 1)
# Reducing stack by rule 782 (line 5774):
# -> $$ = nterm none (2.4-2.4: )
# Stack now 0 2 71 316 124 431
# Entering state 581
# Reducing stack by rule 269 (line 2668):
#    $1 = nterm none (2.4-2.4: )
# -> $$ = nterm lex_ctxt (2.4-2.4: )
# Stack now 0 2 71 316 124 431
# Entering state 660
# Next token is token "integer literal" (2.5-2.6: 1)
# Shifting token "integer literal" (2.5-2.6: 1)
# Entering state 41
# Reducing stack by rule 642 (line 5048):
#    $1 = token "integer literal" (2.5-2.6: 1)
# -> $$ = nterm simple_numeric (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 120
# Reducing stack by rule 640 (line 5037):
#    $1 = nterm simple_numeric (2.5-2.6: )
# -> $$ = nterm numeric (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 119
# Reducing stack by rule 590 (line 4661):
#    $1 = nterm numeric (2.5-2.6: )
# -> $$ = nterm literal (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 106
# Reducing stack by rule 307 (line 2938):
#    $1 = nterm literal (2.5-2.6: )
# -> $$ = nterm primary (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 90
# Reading a token:
# lex_state: END -> BEG at line 9365
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 261 (line 2641):
#    $1 = nterm primary (2.5-2.6: )
# -> $$ = nterm arg (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 876
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 275 (line 2702):
#    $1 = nterm arg (2.5-2.6: )
# -> $$ = nterm arg_rhs (2.5-2.6: )
# Stack now 0 2 71 316 124 431 660
# Entering state 877
# Reducing stack by rule 215 (line 2371):
#    $1 = nterm var_lhs (2.0-2.1: )
#    $2 = token "operator-assignment" (2.2-2.4: +)
#    $3 = nterm lex_ctxt (2.4-2.4: )
#    $4 = nterm arg_rhs (2.5-2.6: )
# -> $$ = nterm arg (2.0-2.6: )
# Stack now 0 2 71 316
# Entering state 88
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 64 (line 1792):
#    $1 = nterm arg (2.0-2.6: )
# -> $$ = nterm expr (2.0-2.6: )
# Stack now 0 2 71 316
# Entering state 75
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 39 (line 1608):
#    $1 = nterm expr (2.0-2.6: )
# -> $$ = nterm stmt (2.0-2.6: )
# Stack now 0 2 71 316
# Entering state 73
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 8 (line 1386):
#    $1 = nterm stmt (2.0-2.6: )
# -> $$ = nterm top_stmt (2.0-2.6: )
# Stack now 0 2 71 316
# Entering state 523
# Reducing stack by rule 6 (line 1373):
#    $1 = nterm top_stmts (1.0-1.5: )
#    $2 = nterm terms (1.5-1.5: )
#    $3 = nterm top_stmt (2.0-2.6: )
# -> $$ = nterm top_stmts (1.0-2.6: )
# Stack now 0 2
# Entering state 71
# Next token is token '\n' (2.6-2.6: )
# Shifting token '\n' (2.6-2.6: )
# Entering state 313
# Reducing stack by rule 779 (line 5766):
#    $1 = token '\n' (2.6-2.6: )
# -> $$ = nterm term (2.6-2.6: )
# Stack now 0 2 71
# Entering state 315
# Reducing stack by rule 780 (line 5769):
#    $1 = nterm term (2.6-2.6: )
# -> $$ = nterm terms (2.6-2.6: )
# Stack now 0 2 71
# Entering state 316
# Reading a token: Now at end of input.
# Reducing stack by rule 769 (line 5744):
#    $1 = nterm terms (2.6-2.6: )
# -> $$ = nterm opt_terms (2.6-2.6: )
# Stack now 0 2 71
# Entering state 314
# Reducing stack by rule 3 (line 1353):
#    $1 = nterm top_stmts (1.0-2.6: )
#    $2 = nterm opt_terms (2.6-2.6: )
# -> $$ = nterm top_compstmt (1.0-2.6: )
# Stack now 0 2
# Entering state 70
# Reducing stack by rule 2 (line 1327):
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-2.6: )
# vtable_free:12604: p->lvtbl->args(0x0000600003376ee0)
# vtable_free:12605: p->lvtbl->vars(0x0000600003376f00)
# cmdarg_stack(pop): 0 at line 12606
# cond_stack(pop): 0 at line 12607
# -> $$ = nterm program (1.0-2.6: )
# Stack now 0
# Entering state 1
# Now at end of input.
# Shifting token "end-of-input" (2.6-2.6: )
# Entering state 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (2.6-2.6: )
# Cleanup: popping nterm program (1.0-2.6: )