### [スキャナパターン] `$ ./ruby -yce "i = 0; i++"`

```
-------------------- i = 0 --------------------

add_delayed_token:7062 (0: 0|0|0)
Starting parse
Entering state 0
Stack now 0
Reducing stack by rule 1 (line 1580):
lex_state: NONE -> BEG at line 1581
vtable_alloc:13147: 0x000060000293c000
vtable_alloc:13148: 0x000060000293c020
cmdarg_stack(push): 0 at line 13161
cond_stack(push): 0 at line 13162
-> $$ = nterm $@1 (1.0-1.0: )
Entering state 2
Stack now 0 2
Reading a token
lex_state: BEG -> CMDARG at line 9733
parser_dispatch_scan_event:10516 (1: 0|1|10)
Next token is token "local variable or method" (1.0-1.1: i)
Shifting token "local variable or method" (1.0-1.1: i)
Entering state 35
Stack now 0 2 35
Reading a token
parser_dispatch_scan_event:9836 (1: 1|1|9)
lex_state: CMDARG -> BEG at line 9996
parser_dispatch_scan_event:10516 (1: 2|1|8)
Next token is token '=' (1.2-1.3: )
Reducing stack by rule 652 (line 5394):
   $1 = token "local variable or method" (1.0-1.1: i)
-> $$ = nterm user_variable (1.0-1.1: )
Entering state 122
Stack now 0 2 122
Next token is token '=' (1.2-1.3: )
Reducing stack by rule 121 (line 2445):
   $1 = nterm user_variable (1.0-1.1: )
vtable_add:13248: p->lvtbl->vars(0x000060000293c020), i
-> $$ = nterm lhs (1.0-1.1: NODE_LASGN)
Entering state 87
Stack now 0 2 87
Next token is token '=' (1.2-1.3: )
Shifting token '=' (1.2-1.3: )
Entering state 343
Stack now 0 2 87 343
Reducing stack by rule 781 (line 6127):
-> $$ = nterm none (1.3-1.3: )
Entering state 577
Stack now 0 2 87 343 577
Reducing stack by rule 270 (line 2929):
   $1 = nterm none (1.3-1.3: )
-> $$ = nterm lex_ctxt (1.3-1.3: )
Entering state 582
Stack now 0 2 87 343 582
Reading a token
parser_dispatch_scan_event:9836 (1: 3|1|7)
lex_state: BEG -> END at line 9005
lex_state: END -> END at line 8282
parser_dispatch_scan_event:10516 (1: 4|1|6)
Next token is token "integer literal" (1.4-1.5: 0)
Shifting token "integer literal" (1.4-1.5: 0)
Entering state 41
Stack now 0 2 87 343 582 41
Reducing stack by rule 645 (line 5383):
   $1 = token "integer literal" (1.4-1.5: 0)
-> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)
Entering state 120
Stack now 0 2 87 343 582 120
Reducing stack by rule 643 (line 5372):
   $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm numeric (1.4-1.5: NODE_LIT)
Entering state 119
Stack now 0 2 87 343 582 119
Reducing stack by rule 595 (line 4998):
   $1 = nterm numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm literal (1.4-1.5: NODE_LIT)
Entering state 106
Stack now 0 2 87 343 582 106
Reducing stack by rule 310 (line 3220):
   $1 = nterm literal (1.4-1.5: NODE_LIT)
-> $$ = nterm primary (1.4-1.5: NODE_LIT)
Entering state 90
Stack now 0 2 87 343 582 90
Reading a token
lex_state: END -> BEG at line 10361
parser_dispatch_scan_event:10516 (1: 5|1|5)
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.4-1.5: NODE_LIT)
Entering state 772
Stack now 0 2 87 343 582 772
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 276 (line 2963):
   $1 = nterm arg (1.4-1.5: NODE_LIT)
-> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)
Entering state 774
Stack now 0 2 87 343 582 774
Reducing stack by rule 216 (line 2629):
   $1 = nterm lhs (1.0-1.1: NODE_LASGN)
   $2 = token '=' (1.2-1.3: )
   $3 = nterm lex_ctxt (1.3-1.3: )
   $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.0-1.5: NODE_LASGN)
Entering state 88
Stack now 0 2 88
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 65 (line 2051):
   $1 = nterm arg (1.0-1.5: NODE_LASGN)
-> $$ = nterm expr (1.0-1.5: NODE_LASGN)
Entering state 75
Stack now 0 2 75
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 37 (line 1853):
   $1 = nterm expr (1.0-1.5: NODE_LASGN)
-> $$ = nterm stmt (1.0-1.5: NODE_LASGN)
Entering state 73
Stack now 0 2 73
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 7 (line 1635):
   $1 = nterm stmt (1.0-1.5: NODE_LASGN)
-> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)
Entering state 72
Stack now 0 2 72
Reducing stack by rule 5 (line 1619):
   $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
-> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)
Entering state 71
Stack now 0 2 71
Next token is token ';' (1.5-1.6: )
Shifting token ';' (1.5-1.6: )
Entering state 309
Stack now 0 2 71 309
Reducing stack by rule 777 (line 6114):
   $1 = token ';' (1.5-1.6: )
-> $$ = nterm term (1.5-1.6: )
Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 779 (line 6122):
   $1 = nterm term (1.5-1.6: )
-> $$ = nterm terms (1.5-1.6: )

-------------------- i++ --------------------

Entering state 313
Stack now 0 2 71 313
Reading a token
parser_dispatch_scan_event:9836 (1: 6|1|4)
lex_state: BEG -> CMDARG at line 9733
lex_state: CMDARG -> END|LABEL at line 9751
parser_dispatch_scan_event:10516 (1: 7|1|3)
Next token is token "local variable or method" (1.7-1.8: i)
Shifting token "local variable or method" (1.7-1.8: i)

Entering state 35
Stack now 0 2 71 313 35
Reading a token
lex_state: END|LABEL -> BEG at line 10167
parser_dispatch_scan_event:10516 (1: 8|1|2)
Next token is token "operator-assignment" (1.8-1.9: +)
Reducing stack by rule 652 (line 5394):
   $1 = token "local variable or method" (1.7-1.8: i)
-> $$ = nterm user_variable (1.7-1.8: )

Entering state 122
Stack now 0 2 71 313 122
Next token is token "operator-assignment" (1.8-1.9: +)
Reducing stack by rule 664 (line 5430):
   $1 = nterm user_variable (1.7-1.8: )
-> $$ = nterm var_lhs (1.7-1.8: NODE_LASGN)

Entering state 125
Stack now 0 2 71 313 125
Next token is token "operator-assignment" (1.8-1.9: +)
Shifting token "operator-assignment" (1.8-1.9: +)

Entering state 429
Stack now 0 2 71 313 125 429
Reducing stack by rule 781 (line 6127):
-> $$ = nterm none (1.9-1.9: )

Entering state 577
Stack now 0 2 71 313 125 429 577
Reducing stack by rule 270 (line 2929):
   $1 = nterm none (1.9-1.9: )
-> $$ = nterm lex_ctxt (1.9-1.9: )

Entering state 658
Stack now 0 2 71 313 125 429 658
Reading a token
lex_state: BEG -> END at line 8282
parser_dispatch_scan_event:10516 (1: 9|1|1)
Next token is token "integer literal" (1.9-1.10: 1)
Shifting token "integer literal" (1.9-1.10: 1)

Entering state 41
Stack now 0 2 71 313 125 429 658 41
Reducing stack by rule 645 (line 5383):
   $1 = token "integer literal" (1.9-1.10: 1)
-> $$ = nterm simple_numeric (1.9-1.10: NODE_LIT)

Entering state 120
Stack now 0 2 71 313 125 429 658 120
Reducing stack by rule 643 (line 5372):
   $1 = nterm simple_numeric (1.9-1.10: NODE_LIT)
-> $$ = nterm numeric (1.9-1.10: NODE_LIT)

Entering state 119
Stack now 0 2 71 313 125 429 658 119
Reducing stack by rule 595 (line 4998):
   $1 = nterm numeric (1.9-1.10: NODE_LIT)
-> $$ = nterm literal (1.9-1.10: NODE_LIT)

Entering state 106
Stack now 0 2 71 313 125 429 658 106
Reducing stack by rule 310 (line 3220):
   $1 = nterm literal (1.9-1.10: NODE_LIT)
-> $$ = nterm primary (1.9-1.10: NODE_LIT)

Entering state 90
Stack now 0 2 71 313 125 429 658 90
Reading a token
lex_state: END -> BEG at line 9903
parser_dispatch_scan_event:10516 (1: 10|1|0)
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.9-1.10: NODE_LIT)
-> $$ = nterm arg (1.9-1.10: NODE_LIT)

Entering state 832
Stack now 0 2 71 313 125 429 658 832
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 276 (line 2963):
   $1 = nterm arg (1.9-1.10: NODE_LIT)
-> $$ = nterm arg_rhs (1.9-1.10: NODE_LIT)

Entering state 833
Stack now 0 2 71 313 125 429 658 833
Reducing stack by rule 217 (line 2636):
   $1 = nterm var_lhs (1.7-1.8: NODE_LASGN)
   $2 = token "operator-assignment" (1.8-1.9: +)
   $3 = nterm lex_ctxt (1.9-1.9: )
   $4 = nterm arg_rhs (1.9-1.10: NODE_LIT)
-> $$ = nterm arg (1.7-1.10: NODE_LASGN)

Entering state 88
Stack now 0 2 71 313 88
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 65 (line 2051):
   $1 = nterm arg (1.7-1.10: NODE_LASGN)
-> $$ = nterm expr (1.7-1.10: NODE_LASGN)

Entering state 75
Stack now 0 2 71 313 75
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 37 (line 1853):
   $1 = nterm expr (1.7-1.10: NODE_LASGN)
-> $$ = nterm stmt (1.7-1.10: NODE_LASGN)

Entering state 73
Stack now 0 2 71 313 73
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 7 (line 1635):
   $1 = nterm stmt (1.7-1.10: NODE_LASGN)
-> $$ = nterm top_stmt (1.7-1.10: NODE_LASGN)

Entering state 520
Stack now 0 2 71 313 520
Reducing stack by rule 6 (line 1626):
   $1 = nterm top_stmts (1.0-1.5: NODE_LASGN)
   $2 = nterm terms (1.5-1.6: )
   $3 = nterm top_stmt (1.7-1.10: NODE_LASGN)
-> $$ = nterm top_stmts (1.0-1.10: NODE_BLOCK)

Entering state 71
Stack now 0 2 71
Next token is token '\n' (1.10-1.11: )
Shifting token '\n' (1.10-1.11: )

Entering state 310
Stack now 0 2 71 310
Reducing stack by rule 778 (line 6115):
   $1 = token '\n' (1.10-1.11: )
-> $$ = nterm term (1.10-1.10: )

Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 779 (line 6122):
   $1 = nterm term (1.10-1.10: )
-> $$ = nterm terms (1.10-1.10: )

Entering state 313
Stack now 0 2 71 313
Reading a token
Now at end of input.
Reducing stack by rule 769 (line 6094):
   $1 = nterm terms (1.10-1.10: )
-> $$ = nterm opt_terms (1.10-1.10: )

Entering state 311
Stack now 0 2 71 311
Reducing stack by rule 3 (line 1606):
   $1 = nterm top_stmts (1.0-1.10: NODE_BLOCK)
   $2 = nterm opt_terms (1.10-1.10: )
-> $$ = nterm top_compstmt (1.0-1.10: NODE_BLOCK)

Entering state 70
Stack now 0 2 70
Reducing stack by rule 2 (line 1580):
   $1 = nterm $@1 (1.0-1.0: )
   $2 = nterm top_compstmt (1.0-1.10: NODE_BLOCK)
vtable_free:13181: p->lvtbl->args(0x000060000293c000)
vtable_free:13182: p->lvtbl->vars(0x000060000293c020)
cmdarg_stack(pop): 0 at line 13183
cond_stack(pop): 0 at line 13184
-> $$ = nterm program (1.0-1.10: )

Entering state 1
Stack now 0 1
Now at end of input.
Shifting token "end-of-input" (1.11-1.11: )

Entering state 3
Stack now 0 1 3
Stack now 0 1 3
Cleanup: popping token "end-of-input" (1.11-1.11: )
Cleanup: popping nterm program (1.0-1.10: )
Syntax OK
```
