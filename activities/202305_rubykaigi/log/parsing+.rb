i = 0
n = 1
i + n

# $ ruby -yc activities/rubypp/log/parsing+.rb
#
# add_delayed_token:7062 (0: 0|0|0)
# Starting parse
#
# Entering state 0
# Stack now 0
# Reducing stack by rule 1 (line 1580):
# lex_state: NONE -> BEG at line 1581
# vtable_alloc:13130: 0x00006000030286a0
# vtable_alloc:13131: 0x00006000030286c0
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm $@1 (1.0-1.0: )
#
# Entering state 2
# Stack now 0 2
# Reading a token
# lex_state: BEG -> CMDARG at line 9733
# parser_dispatch_scan_event:10499 (1: 0|1|5)
# Next token is token "local variable or method" (1.0-1.1: i)
# Shifting token "local variable or method" (1.0-1.1: i)
#
# Entering state 35
# Stack now 0 2 35
# Reading a token
# parser_dispatch_scan_event:9833 (1: 1|1|4)
# lex_state: CMDARG -> BEG at line 9993
# parser_dispatch_scan_event:10499 (1: 2|1|3)
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (1.0-1.1: i)
# -> $$ = nterm user_variable (1.0-1.1: )
#
# Entering state 122
# Stack now 0 2 122
# Next token is token '=' (1.2-1.3: )
# Reducing stack by rule 121 (line 2445):
#    $1 = nterm user_variable (1.0-1.1: )
# vtable_add:13231: p->lvtbl->vars(0x00006000030286c0), i
# -> $$ = nterm lhs (1.0-1.1: NODE_LASGN)
#
# Entering state 87
# Stack now 0 2 87
# Next token is token '=' (1.2-1.3: )
# Shifting token '=' (1.2-1.3: )
#
# Entering state 343
# Stack now 0 2 87 343
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (1.3-1.3: )
#
# Entering state 577
# Stack now 0 2 87 343 577
# Reducing stack by rule 270 (line 2929):
#    $1 = nterm none (1.3-1.3: )
# -> $$ = nterm lex_ctxt (1.3-1.3: )
#
# Entering state 582
# Stack now 0 2 87 343 582
# Reading a token
# parser_dispatch_scan_event:9833 (1: 3|1|2)
# lex_state: BEG -> END at line 9005
# lex_state: END -> END at line 8282
# parser_dispatch_scan_event:10499 (1: 4|1|1)
# Next token is token "integer literal" (1.4-1.5: 0)
# Shifting token "integer literal" (1.4-1.5: 0)
#
# Entering state 41
# Stack now 0 2 87 343 582 41
# Reducing stack by rule 645 (line 5383):
#    $1 = token "integer literal" (1.4-1.5: 0)
# -> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)
#
# Entering state 120
# Stack now 0 2 87 343 582 120
# Reducing stack by rule 643 (line 5372):
#    $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm numeric (1.4-1.5: NODE_LIT)
#
# Entering state 119
# Stack now 0 2 87 343 582 119
# Reducing stack by rule 595 (line 4998):
#    $1 = nterm numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm literal (1.4-1.5: NODE_LIT)
#
# Entering state 106
# Stack now 0 2 87 343 582 106
# Reducing stack by rule 310 (line 3220):
#    $1 = nterm literal (1.4-1.5: NODE_LIT)
# -> $$ = nterm primary (1.4-1.5: NODE_LIT)
#
# Entering state 90
# Stack now 0 2 87 343 582 90
# Reading a token
# add_delayed_token:7062 (1: 5|1|0)
# lex_state: END -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (1: 6|0|0)
# Next token is token '\n' (1.5-1.6: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.4-1.5: NODE_LIT)
#
# Entering state 772
# Stack now 0 2 87 343 582 772
# Next token is token '\n' (1.5-1.6: )
# Reducing stack by rule 276 (line 2963):
#    $1 = nterm arg (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)
#
# Entering state 774
# Stack now 0 2 87 343 582 774
# Reducing stack by rule 216 (line 2629):
#    $1 = nterm lhs (1.0-1.1: NODE_LASGN)
#    $2 = token '=' (1.2-1.3: )
#    $3 = nterm lex_ctxt (1.3-1.3: )
#    $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.0-1.5: NODE_LASGN)
#
# Entering state 88
# Stack now 0 2 88
# Next token is token '\n' (1.5-1.6: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (1.0-1.5: NODE_LASGN)
# -> $$ = nterm expr (1.0-1.5: NODE_LASGN)
#
# Entering state 75
# Stack now 0 2 75
# Next token is token '\n' (1.5-1.6: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (1.0-1.5: NODE_LASGN)
# -> $$ = nterm stmt (1.0-1.5: NODE_LASGN)
#
# Entering state 73
# Stack now 0 2 73
# Next token is token '\n' (1.5-1.6: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)
#
# Entering state 72
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1619):
#    $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (1.5-1.6: )
# Shifting token '\n' (1.5-1.6: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (1.5-1.6: )
# -> $$ = nterm term (1.5-1.5: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (1.5-1.5: )
# -> $$ = nterm terms (1.5-1.5: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# add_delayed_token:7062 (1: 6|0|0)
# lex_state: BEG -> CMDARG at line 9733
# parser_dispatch_scan_event:10499 (2: 0|1|5)
# Next token is token "local variable or method" (2.0-2.1: n)
# Shifting token "local variable or method" (2.0-2.1: n)
#
# Entering state 35
# Stack now 0 2 71 313 35
# Reading a token
# parser_dispatch_scan_event:9833 (2: 1|1|4)
# lex_state: CMDARG -> BEG at line 9993
# parser_dispatch_scan_event:10499 (2: 2|1|3)
# Next token is token '=' (2.2-2.3: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (2.0-2.1: n)
# -> $$ = nterm user_variable (2.0-2.1: )
#
# Entering state 122
# Stack now 0 2 71 313 122
# Next token is token '=' (2.2-2.3: )
# Reducing stack by rule 121 (line 2445):
#    $1 = nterm user_variable (2.0-2.1: )
# vtable_add:13231: p->lvtbl->vars(0x00006000030286c0), n
# -> $$ = nterm lhs (2.0-2.1: NODE_LASGN)
#
# Entering state 87
# Stack now 0 2 71 313 87
# Next token is token '=' (2.2-2.3: )
# Shifting token '=' (2.2-2.3: )
#
# Entering state 343
# Stack now 0 2 71 313 87 343
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (2.3-2.3: )
#
# Entering state 577
# Stack now 0 2 71 313 87 343 577
# Reducing stack by rule 270 (line 2929):
#    $1 = nterm none (2.3-2.3: )
# -> $$ = nterm lex_ctxt (2.3-2.3: )
#
# Entering state 582
# Stack now 0 2 71 313 87 343 582
# Reading a token
# parser_dispatch_scan_event:9833 (2: 3|1|2)
# lex_state: BEG -> END at line 9005
# lex_state: END -> END at line 8282
# parser_dispatch_scan_event:10499 (2: 4|1|1)
# Next token is token "integer literal" (2.4-2.5: 1)
# Shifting token "integer literal" (2.4-2.5: 1)
#
# Entering state 41
# Stack now 0 2 71 313 87 343 582 41
# Reducing stack by rule 645 (line 5383):
#    $1 = token "integer literal" (2.4-2.5: 1)
# -> $$ = nterm simple_numeric (2.4-2.5: NODE_LIT)
#
# Entering state 120
# Stack now 0 2 71 313 87 343 582 120
# Reducing stack by rule 643 (line 5372):
#    $1 = nterm simple_numeric (2.4-2.5: NODE_LIT)
# -> $$ = nterm numeric (2.4-2.5: NODE_LIT)
#
# Entering state 119
# Stack now 0 2 71 313 87 343 582 119
# Reducing stack by rule 595 (line 4998):
#    $1 = nterm numeric (2.4-2.5: NODE_LIT)
# -> $$ = nterm literal (2.4-2.5: NODE_LIT)
#
# Entering state 106
# Stack now 0 2 71 313 87 343 582 106
# Reducing stack by rule 310 (line 3220):
#    $1 = nterm literal (2.4-2.5: NODE_LIT)
# -> $$ = nterm primary (2.4-2.5: NODE_LIT)
#
# Entering state 90
# Stack now 0 2 71 313 87 343 582 90
# Reading a token
# add_delayed_token:7062 (2: 5|1|0)
# lex_state: END -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (2: 6|0|0)
# Next token is token '\n' (2.5-2.6: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (2.4-2.5: NODE_LIT)
# -> $$ = nterm arg (2.4-2.5: NODE_LIT)
#
# Entering state 772
# Stack now 0 2 71 313 87 343 582 772
# Next token is token '\n' (2.5-2.6: )
# Reducing stack by rule 276 (line 2963):
#    $1 = nterm arg (2.4-2.5: NODE_LIT)
# -> $$ = nterm arg_rhs (2.4-2.5: NODE_LIT)
#
# Entering state 774
# Stack now 0 2 71 313 87 343 582 774
# Reducing stack by rule 216 (line 2629):
#    $1 = nterm lhs (2.0-2.1: NODE_LASGN)
#    $2 = token '=' (2.2-2.3: )
#    $3 = nterm lex_ctxt (2.3-2.3: )
#    $4 = nterm arg_rhs (2.4-2.5: NODE_LIT)
# -> $$ = nterm arg (2.0-2.5: NODE_LASGN)
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '\n' (2.5-2.6: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (2.0-2.5: NODE_LASGN)
# -> $$ = nterm expr (2.0-2.5: NODE_LASGN)
#
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (2.5-2.6: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (2.0-2.5: NODE_LASGN)
# -> $$ = nterm stmt (2.0-2.5: NODE_LASGN)
#
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (2.5-2.6: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (2.0-2.5: NODE_LASGN)
# -> $$ = nterm top_stmt (2.0-2.5: NODE_LASGN)
#
# Entering state 520
# Stack now 0 2 71 313 520
# Reducing stack by rule 6 (line 1626):
#    $1 = nterm top_stmts (1.0-1.5: NODE_LASGN)
#    $2 = nterm terms (1.5-1.5: )
#    $3 = nterm top_stmt (2.0-2.5: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-2.5: NODE_BLOCK)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (2.5-2.6: )
# Shifting token '\n' (2.5-2.6: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (2.5-2.6: )
# -> $$ = nterm term (2.5-2.5: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (2.5-2.5: )
# -> $$ = nterm terms (2.5-2.5: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# add_delayed_token:7062 (2: 6|0|0)
# lex_state: BEG -> CMDARG at line 9733
# lex_state: CMDARG -> END|LABEL at line 9751
# parser_dispatch_scan_event:10499 (3: 0|1|5)
# Next token is token "local variable or method" (3.0-3.1: i)
# Shifting token "local variable or method" (3.0-3.1: i)
#
# Entering state 35
# Stack now 0 2 71 313 35
# Reading a token
# parser_dispatch_scan_event:9833 (3: 1|1|4)
# lex_state: END|LABEL -> BEG at line 10181
# parser_dispatch_scan_event:10499 (3: 2|1|3)
# Next token is token '+' (3.2-3.3: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (3.0-3.1: i)
# -> $$ = nterm user_variable (3.0-3.1: )
#
# Entering state 122
# Stack now 0 2 71 313 122
# Next token is token '+' (3.2-3.3: )
# Reducing stack by rule 662 (line 5408):
#    $1 = nterm user_variable (3.0-3.1: )
# -> $$ = nterm var_ref (3.0-3.1: NODE_LVAR)
#
# Entering state 124
# Stack now 0 2 71 313 124
# Reducing stack by rule 318 (line 3228):
#    $1 = nterm var_ref (3.0-3.1: NODE_LVAR)
# -> $$ = nterm primary (3.0-3.1: NODE_LVAR)
#
# Entering state 90
# Stack now 0 2 71 313 90
# Next token is token '+' (3.2-3.3: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (3.0-3.1: NODE_LVAR)
# -> $$ = nterm arg (3.0-3.1: NODE_LVAR)
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '+' (3.2-3.3: )
# Shifting token '+' (3.2-3.3: )
#
# Entering state 367
# Stack now 0 2 71 313 88 367
# Reading a token
# parser_dispatch_scan_event:9833 (3: 3|1|2)
# lex_state: BEG -> ARG at line 9736
# lex_state: ARG -> END|LABEL at line 9751
# parser_dispatch_scan_event:10499 (3: 4|1|1)
# Next token is token "local variable or method" (3.4-3.5: n)
# Shifting token "local variable or method" (3.4-3.5: n)
#
# Entering state 35
# Stack now 0 2 71 313 88 367 35
# Reading a token
# lex_state: END|LABEL -> BEG at line 9900
# parser_dispatch_scan_event:10499 (3: 5|1|0)
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (3.4-3.5: n)
# -> $$ = nterm user_variable (3.4-3.5: )
#
# Entering state 228
# Stack now 0 2 71 313 88 367 228
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 662 (line 5408):
#    $1 = nterm user_variable (3.4-3.5: )
# -> $$ = nterm var_ref (3.4-3.5: NODE_LVAR)
#
# Entering state 124
# Stack now 0 2 71 313 88 367 124
# Reducing stack by rule 318 (line 3228):
#    $1 = nterm var_ref (3.4-3.5: NODE_LVAR)
# -> $$ = nterm primary (3.4-3.5: NODE_LVAR)
#
# Entering state 90
# Stack now 0 2 71 313 88 367 90
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (3.4-3.5: NODE_LVAR)
# -> $$ = nterm arg (3.4-3.5: NODE_LVAR)
#
# Entering state 602
# Stack now 0 2 71 313 88 367 602
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 231 (line 2745):
#    $1 = nterm arg (3.0-3.1: NODE_LVAR)
#    $2 = token '+' (3.2-3.3: )
#    $3 = nterm arg (3.4-3.5: NODE_LVAR)
# -> $$ = nterm arg (3.0-3.5: NODE_OPCALL)
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (3.0-3.5: NODE_OPCALL)
# -> $$ = nterm expr (3.0-3.5: NODE_OPCALL)
#
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (3.0-3.5: NODE_OPCALL)
# -> $$ = nterm stmt (3.0-3.5: NODE_OPCALL)
#
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (3.5-3.6: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (3.0-3.5: NODE_OPCALL)
# -> $$ = nterm top_stmt (3.0-3.5: NODE_OPCALL)
#
# Entering state 520
# Stack now 0 2 71 313 520
# Reducing stack by rule 6 (line 1626):
#    $1 = nterm top_stmts (1.0-2.5: NODE_BLOCK)
#    $2 = nterm terms (2.5-2.5: )
#    $3 = nterm top_stmt (3.0-3.5: NODE_OPCALL)
# -> $$ = nterm top_stmts (1.0-3.5: NODE_BLOCK)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (3.5-3.6: )
# Shifting token '\n' (3.5-3.6: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (3.5-3.6: )
# -> $$ = nterm term (3.5-3.5: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (3.5-3.5: )
# -> $$ = nterm terms (3.5-3.5: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# Now at end of input.
# Reducing stack by rule 769 (line 6094):
#    $1 = nterm terms (3.5-3.5: )
# -> $$ = nterm opt_terms (3.5-3.5: )
#
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1606):
#    $1 = nterm top_stmts (1.0-3.5: NODE_BLOCK)
#    $2 = nterm opt_terms (3.5-3.5: )
# -> $$ = nterm top_compstmt (1.0-3.5: NODE_BLOCK)
#
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1580):
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-3.5: NODE_BLOCK)
# vtable_free:13164: p->lvtbl->args(0x00006000030286a0)
# vtable_free:13165: p->lvtbl->vars(0x00006000030286c0)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm program (1.0-3.5: )
#
# Entering state 1
# Stack now 0 1
# Now at end of input.
# Shifting token "end-of-input" (3.6-3.6: )
#
# Entering state 3
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (3.6-3.6: )
# Cleanup: popping nterm program (1.0-3.5: )
# Syntax OK
