```
$ ruby -yce "'鹿児島Ruby会議' + '02'"

add_delayed_token:7062 (0: 0|0|0)

Starting parse
Entering state 0
Stack now 0
Reducing stack by rule 1 (line 1580):
lex_state: NONE -> BEG at line 1581
vtable_alloc:13130: 0x00006000026a9ea0
vtable_alloc:13131: 0x00006000026a9ec0
cmdarg_stack(push): 0 at line 13144
cond_stack(push): 0 at line 13145
-> $$ = nterm $@1 (1.0-1.0: )

Entering state 2
Stack now 0 2
Reading a token
parser_dispatch_scan_event:10499 (1: 0|1|28)
Next token is token "string literal" (1.0-1.1: )
Shifting token "string literal" (1.0-1.1: )

Entering state 60
Stack now 0 2 60
Reducing stack by rule 618 (line 5167):
-> $$ = nterm string_contents (1.1-1.1: )

Entering state 298
Stack now 0 2 60 298
Reading a token
parser_dispatch_scan_event:7819 (1: 1|19|9)
parser_dispatch_scan_event:10499 (1: 20|0|9)
Next token is token "literal content" (1.1-1.20: "鹿児島Ruby会議")
Shifting token "literal content" (1.1-1.20: "鹿児島Ruby会議")

Entering state 504
Stack now 0 2 60 298 504
Reducing stack by rule 624 (line 5263):
   $1 = token "literal content" (1.1-1.20: "鹿児島Ruby会議")
-> $$ = nterm string_content (1.1-1.20: NODE_STR)

Entering state 508
Stack now 0 2 60 298 508
Reducing stack by rule 619 (line 5177):
   $1 = nterm string_contents (1.1-1.1: )
   $2 = nterm string_content (1.1-1.20: NODE_STR)
-> $$ = nterm string_contents (1.1-1.20: NODE_STR)

Entering state 298
Stack now 0 2 60 298
Reading a token
lex_state: BEG -> END at line 7905
parser_dispatch_scan_event:10499 (1: 20|1|8)
Next token is token "terminator" (1.20-1.21: )
Shifting token "terminator" (1.20-1.21: )

Entering state 509
Stack now 0 2 60 298 509
Reducing stack by rule 601 (line 5030):
   $1 = token "string literal" (1.0-1.1: )
   $2 = nterm string_contents (1.1-1.20: NODE_STR)
   $3 = token "terminator" (1.20-1.21: )
-> $$ = nterm string1 (1.0-1.21: NODE_STR)

Entering state 109
Stack now 0 2 109
Reducing stack by rule 599 (line 5020):
   $1 = nterm string1 (1.0-1.21: NODE_STR)
-> $$ = nterm string (1.0-1.21: NODE_STR)

Entering state 108
Stack now 0 2 108
Reading a token
parser_dispatch_scan_event:9833 (1: 21|1|7)
lex_state: END -> BEG at line 10181
parser_dispatch_scan_event:10499 (1: 22|1|6)
Next token is token '+' (1.22-1.23: )
Reducing stack by rule 597 (line 5002):
   $1 = nterm string (1.0-1.21: NODE_STR)
-> $$ = nterm strings (1.0-1.21: NODE_STR)

Entering state 107
Stack now 0 2 107
Reducing stack by rule 311 (line 3221):
   $1 = nterm strings (1.0-1.21: NODE_STR)
-> $$ = nterm primary (1.0-1.21: NODE_STR)

Entering state 90
Stack now 0 2 90
Next token is token '+' (1.22-1.23: )
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.0-1.21: NODE_STR)
-> $$ = nterm arg (1.0-1.21: NODE_STR)

Entering state 88
Stack now 0 2 88
Next token is token '+' (1.22-1.23: )
Shifting token '+' (1.22-1.23: )

Entering state 367
Stack now 0 2 88 367
Reading a token
parser_dispatch_scan_event:9833 (1: 23|1|5)
parser_dispatch_scan_event:10499 (1: 24|1|4)
Next token is token "string literal" (1.24-1.25: )
Shifting token "string literal" (1.24-1.25: )

Entering state 60
Stack now 0 2 88 367 60
Reducing stack by rule 618 (line 5167):
-> $$ = nterm string_contents (1.25-1.25: )

Entering state 298
Stack now 0 2 88 367 60 298
Reading a token
parser_dispatch_scan_event:7819 (1: 25|2|2)
parser_dispatch_scan_event:10499 (1: 27|0|2)
Next token is token "literal content" (1.25-1.27: "02")
Shifting token "literal content" (1.25-1.27: "02")

Entering state 504
Stack now 0 2 88 367 60 298 504
Reducing stack by rule 624 (line 5263):
   $1 = token "literal content" (1.25-1.27: "02")
-> $$ = nterm string_content (1.25-1.27: NODE_STR)

Entering state 508
Stack now 0 2 88 367 60 298 508
Reducing stack by rule 619 (line 5177):
   $1 = nterm string_contents (1.25-1.25: )
   $2 = nterm string_content (1.25-1.27: NODE_STR)
-> $$ = nterm string_contents (1.25-1.27: NODE_STR)

Entering state 298
Stack now 0 2 88 367 60 298
Reading a token
lex_state: BEG -> END at line 7905
parser_dispatch_scan_event:10499 (1: 27|1|1)
Next token is token "terminator" (1.27-1.28: )
Shifting token "terminator" (1.27-1.28: )

Entering state 509
Stack now 0 2 88 367 60 298 509
Reducing stack by rule 601 (line 5030):
   $1 = token "string literal" (1.24-1.25: )
   $2 = nterm string_contents (1.25-1.27: NODE_STR)
   $3 = token "terminator" (1.27-1.28: )
-> $$ = nterm string1 (1.24-1.28: NODE_STR)

Entering state 109
Stack now 0 2 88 367 109
Reducing stack by rule 599 (line 5020):
   $1 = nterm string1 (1.24-1.28: NODE_STR)
-> $$ = nterm string (1.24-1.28: NODE_STR)

Entering state 108
Stack now 0 2 88 367 108
Reading a token
lex_state: END -> BEG at line 9900
parser_dispatch_scan_event:10499 (1: 28|1|0)
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 597 (line 5002):
   $1 = nterm string (1.24-1.28: NODE_STR)
-> $$ = nterm strings (1.24-1.28: NODE_STR)

Entering state 107
Stack now 0 2 88 367 107
Reducing stack by rule 311 (line 3221):
   $1 = nterm strings (1.24-1.28: NODE_STR)
-> $$ = nterm primary (1.24-1.28: NODE_STR)

Entering state 90
Stack now 0 2 88 367 90
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.24-1.28: NODE_STR)
-> $$ = nterm arg (1.24-1.28: NODE_STR)

Entering state 602
Stack now 0 2 88 367 602
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 231 (line 2745):
   $1 = nterm arg (1.0-1.21: NODE_STR)
   $2 = token '+' (1.22-1.23: )
   $3 = nterm arg (1.24-1.28: NODE_STR)
-> $$ = nterm arg (1.0-1.28: NODE_OPCALL)

Entering state 88
Stack now 0 2 88
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 65 (line 2051):
   $1 = nterm arg (1.0-1.28: NODE_OPCALL)
-> $$ = nterm expr (1.0-1.28: NODE_OPCALL)

Entering state 75
Stack now 0 2 75
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 37 (line 1853):
   $1 = nterm expr (1.0-1.28: NODE_OPCALL)
-> $$ = nterm stmt (1.0-1.28: NODE_OPCALL)

Entering state 73
Stack now 0 2 73
Next token is token '\n' (1.28-1.29: )
Reducing stack by rule 7 (line 1635):
   $1 = nterm stmt (1.0-1.28: NODE_OPCALL)
-> $$ = nterm top_stmt (1.0-1.28: NODE_OPCALL)

Entering state 72
Stack now 0 2 72
Reducing stack by rule 5 (line 1619):
   $1 = nterm top_stmt (1.0-1.28: NODE_OPCALL)
-> $$ = nterm top_stmts (1.0-1.28: NODE_OPCALL)

Entering state 71
Stack now 0 2 71
Next token is token '\n' (1.28-1.29: )
Shifting token '\n' (1.28-1.29: )

Entering state 310
Stack now 0 2 71 310
Reducing stack by rule 778 (line 6115):
   $1 = token '\n' (1.28-1.29: )
-> $$ = nterm term (1.28-1.28: )

Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 779 (line 6122):
   $1 = nterm term (1.28-1.28: )
-> $$ = nterm terms (1.28-1.28: )

Entering state 313
Stack now 0 2 71 313
Reading a token
Now at end of input.
Reducing stack by rule 769 (line 6094):
   $1 = nterm terms (1.28-1.28: )
-> $$ = nterm opt_terms (1.28-1.28: )

Entering state 311
Stack now 0 2 71 311
Reducing stack by rule 3 (line 1606):
   $1 = nterm top_stmts (1.0-1.28: NODE_OPCALL)
   $2 = nterm opt_terms (1.28-1.28: )
-> $$ = nterm top_compstmt (1.0-1.28: NODE_OPCALL)

Entering state 70
Stack now 0 2 70
Reducing stack by rule 2 (line 1580):
   $1 = nterm $@1 (1.0-1.0: )
   $2 = nterm top_compstmt (1.0-1.28: NODE_OPCALL)
vtable_free:13164: p->lvtbl->args(0x00006000026a9ea0)
vtable_free:13165: p->lvtbl->vars(0x00006000026a9ec0)
cmdarg_stack(pop): 0 at line 13166
cond_stack(pop): 0 at line 13167
-> $$ = nterm program (1.0-1.28: )

Entering state 1
Stack now 0 1
Now at end of input.
Shifting token "end-of-input" (1.29-1.29: )

Entering state 3
Stack now 0 1 3
Stack now 0 1 3
Cleanup: popping token "end-of-input" (1.29-1.29: )
Cleanup: popping nterm program (1.0-1.28: )
Syntax OK
```
