#### [パーサパターン] `$ /ruby -yce "i = 0; i++"`

```
-------------------- i = 0 --------------------
add_delayed_token:7100 (0: 0|0|0)
Starting parse
Entering state 0
Stack now 0
Reducing stack by rule 1 (line 1582):
lex_state: NONE -> BEG at line 1583
vtable_alloc:13173: 0x00006000007e01e0
vtable_alloc:13174: 0x00006000007e0200
cmdarg_stack(push): 0 at line 13187
cond_stack(push): 0 at line 13188
-> $$ = nterm $@1 (1.0-1.0: )
Entering state 2
Stack now 0 2
Reading a token
lex_state: BEG -> CMDARG at line 9771
parser_dispatch_scan_event:10542 (1: 0|1|10)
Next token is token "local variable or method" (1.0-1.1: i)
Shifting token "local variable or method" (1.0-1.1: i)
Entering state 35
Stack now 0 2 35
Reading a token
parser_dispatch_scan_event:9871 (1: 1|1|9)
lex_state: CMDARG -> BEG at line 10031
parser_dispatch_scan_event:10542 (1: 2|1|8)
Next token is token '=' (1.2-1.3: )
Reducing stack by rule 653 (line 5432):
   $1 = token "local variable or method" (1.0-1.1: i)
-> $$ = nterm user_variable (1.0-1.1: )
Entering state 122
Stack now 0 2 122
Next token is token '=' (1.2-1.3: )
Reducing stack by rule 121 (line 2447):
   $1 = nterm user_variable (1.0-1.1: )
vtable_add:13274: p->lvtbl->vars(0x00006000007e0200), i
-> $$ = nterm lhs (1.0-1.1: NODE_LASGN)
Entering state 87
Stack now 0 2 87
Next token is token '=' (1.2-1.3: )
Shifting token '=' (1.2-1.3: )
Entering state 343
Stack now 0 2 87 343
Reducing stack by rule 782 (line 6165):
-> $$ = nterm none (1.3-1.3: )
Entering state 431
Stack now 0 2 87 343 431
Reducing stack by rule 271 (line 2967):
   $1 = nterm none (1.3-1.3: )
-> $$ = nterm lex_ctxt (1.3-1.3: )
Entering state 583
Stack now 0 2 87 343 583
Reading a token
parser_dispatch_scan_event:9871 (1: 3|1|7)
lex_state: BEG -> END at line 9043
lex_state: END -> END at line 8320
parser_dispatch_scan_event:10542 (1: 4|1|6)
Next token is token "integer literal" (1.4-1.5: 0)
Shifting token "integer literal" (1.4-1.5: 0)
Entering state 41
Stack now 0 2 87 343 583 41
Reducing stack by rule 646 (line 5421):
   $1 = token "integer literal" (1.4-1.5: 0)
-> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)
Entering state 120
Stack now 0 2 87 343 583 120
Reducing stack by rule 644 (line 5410):
   $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm numeric (1.4-1.5: NODE_LIT)
Entering state 119
Stack now 0 2 87 343 583 119
Reducing stack by rule 596 (line 5036):
   $1 = nterm numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm literal (1.4-1.5: NODE_LIT)
Entering state 106
Stack now 0 2 87 343 583 106
Reducing stack by rule 311 (line 3258):
   $1 = nterm literal (1.4-1.5: NODE_LIT)
-> $$ = nterm primary (1.4-1.5: NODE_LIT)
Entering state 90
Stack now 0 2 87 343 583 90
Reading a token
lex_state: END -> BEG at line 10387
parser_dispatch_scan_event:10542 (1: 5|1|5)
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 264 (line 2944):
   $1 = nterm primary (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.4-1.5: NODE_LIT)
Entering state 774
Stack now 0 2 87 343 583 774
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 277 (line 3001):
   $1 = nterm arg (1.4-1.5: NODE_LIT)
-> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)
Entering state 776
Stack now 0 2 87 343 583 776
Reducing stack by rule 216 (line 2631):
   $1 = nterm lhs (1.0-1.1: NODE_LASGN)
   $2 = token '=' (1.2-1.3: )
   $3 = nterm lex_ctxt (1.3-1.3: )
   $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.0-1.5: NODE_LASGN)
Entering state 88
Stack now 0 2 88
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 65 (line 2053):
   $1 = nterm arg (1.0-1.5: NODE_LASGN)
-> $$ = nterm expr (1.0-1.5: NODE_LASGN)
Entering state 75
Stack now 0 2 75
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 37 (line 1855):
   $1 = nterm expr (1.0-1.5: NODE_LASGN)
-> $$ = nterm stmt (1.0-1.5: NODE_LASGN)
Entering state 73
Stack now 0 2 73
Next token is token ';' (1.5-1.6: )
Reducing stack by rule 7 (line 1637):
   $1 = nterm stmt (1.0-1.5: NODE_LASGN)
-> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)
Entering state 72
Stack now 0 2 72
Reducing stack by rule 5 (line 1621):
   $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
-> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)
Entering state 71
Stack now 0 2 71
Next token is token ';' (1.5-1.6: )
Shifting token ';' (1.5-1.6: )
Entering state 309
Stack now 0 2 71 309
Reducing stack by rule 778 (line 6152):
   $1 = token ';' (1.5-1.6: )
-> $$ = nterm term (1.5-1.6: )

-------------------- i++ --------------------

Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 780 (line 6160):
   $1 = nterm term (1.5-1.6: )
-> $$ = nterm terms (1.5-1.6: )

Entering state 313
Stack now 0 2 71 313
Reading a token
parser_dispatch_scan_event:9871 (1: 6|1|4)
lex_state: BEG -> CMDARG at line 9771
lex_state: CMDARG -> END|LABEL at line 9789
parser_dispatch_scan_event:10542 (1: 7|1|3)
Next token is token "local variable or method" (1.7-1.8: i)
Shifting token "local variable or method" (1.7-1.8: i)

Entering state 35
Stack now 0 2 71 313 35
Reading a token
lex_state: END|LABEL -> BEG at line 10208
parser_dispatch_scan_event:10542 (1: 8|2|1)
Next token is token "increment-operator-assignment" (1.8-1.10: )
Reducing stack by rule 653 (line 5432):
   $1 = token "local variable or method" (1.7-1.8: i)
-> $$ = nterm user_variable (1.7-1.8: )

Entering state 122
Stack now 0 2 71 313 122
Next token is token "increment-operator-assignment" (1.8-1.10: )
Reducing stack by rule 665 (line 5468):
   $1 = nterm user_variable (1.7-1.8: )
-> $$ = nterm var_lhs (1.7-1.8: NODE_LASGN)

Entering state 125
Stack now 0 2 71 313 125
Next token is token "increment-operator-assignment" (1.8-1.10: )
Reducing stack by rule 782 (line 6165):
-> $$ = nterm none (1.8-1.8: )

Entering state 431
Stack now 0 2 71 313 125 431
Reducing stack by rule 271 (line 2967):
   $1 = nterm none (1.8-1.8: )
-> $$ = nterm lex_ctxt (1.8-1.8: )

Entering state 430
Stack now 0 2 71 313 125 430
Next token is token "increment-operator-assignment" (1.8-1.10: )
Shifting token "increment-operator-assignment" (1.8-1.10: )

Entering state 660
Stack now 0 2 71 313 125 430 660
Reducing stack by rule 218 (line 2645):
   $1 = nterm var_lhs (1.7-1.8: NODE_LASGN)
   $2 = nterm lex_ctxt (1.8-1.8: )
   $3 = token "increment-operator-assignment" (1.8-1.10: )
lex_state: BEG -> END at line 2663
-> $$ = nterm arg (1.7-1.10: NODE_LASGN)

Entering state 88
Stack now 0 2 71 313 88
Reading a token
lex_state: END -> BEG at line 9938
parser_dispatch_scan_event:10542 (1: 10|1|0)
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 65 (line 2053):
   $1 = nterm arg (1.7-1.10: NODE_LASGN)
-> $$ = nterm expr (1.7-1.10: NODE_LASGN)

Entering state 75
Stack now 0 2 71 313 75
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 37 (line 1855):
   $1 = nterm expr (1.7-1.10: NODE_LASGN)
-> $$ = nterm stmt (1.7-1.10: NODE_LASGN)

Entering state 73
Stack now 0 2 71 313 73
Next token is token '\n' (1.10-1.11: )
Reducing stack by rule 7 (line 1637):
   $1 = nterm stmt (1.7-1.10: NODE_LASGN)
-> $$ = nterm top_stmt (1.7-1.10: NODE_LASGN)

Entering state 522
Stack now 0 2 71 313 522
Reducing stack by rule 6 (line 1628):
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
Reducing stack by rule 779 (line 6153):
   $1 = token '\n' (1.10-1.11: )
-> $$ = nterm term (1.10-1.10: )

Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 780 (line 6160):
   $1 = nterm term (1.10-1.10: )
-> $$ = nterm terms (1.10-1.10: )

Entering state 313
Stack now 0 2 71 313
Reading a token
Now at end of input.
Reducing stack by rule 770 (line 6132):
   $1 = nterm terms (1.10-1.10: )
-> $$ = nterm opt_terms (1.10-1.10: )

Entering state 311
Stack now 0 2 71 311
Reducing stack by rule 3 (line 1608):
   $1 = nterm top_stmts (1.0-1.10: NODE_BLOCK)
   $2 = nterm opt_terms (1.10-1.10: )
-> $$ = nterm top_compstmt (1.0-1.10: NODE_BLOCK)

Entering state 70
Stack now 0 2 70
Reducing stack by rule 2 (line 1582):
   $1 = nterm $@1 (1.0-1.0: )
   $2 = nterm top_compstmt (1.0-1.10: NODE_BLOCK)
vtable_free:13207: p->lvtbl->args(0x00006000007e01e0)
vtable_free:13208: p->lvtbl->vars(0x00006000007e0200)
cmdarg_stack(pop): 0 at line 13209
cond_stack(pop): 0 at line 13210
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
