```
$ ruby -ye '1 + 2'

add_delayed_token:7062 (0: 0|0|0)
Starting parse                                       構文解析を開始

Entering state 0
Stack now 0
Reducing stack by rule 1 (line 1580):                構文規則1に従って還元を開始
lex_state: NONE -> BEG at line 1581
vtable_alloc:13130: 0x00006000034e9b40
vtable_alloc:13131: 0x00006000034e9b60
cmdarg_stack(push): 0 at line 13144
cond_stack(push): 0 at line 13145
-> $$ = nterm $@1 (1.0-1.0: )

Entering state 2
Stack now 0 2
Reading a token                                     字句解析器が記号を読み込み
lex_state: BEG -> END at line 9005
lex_state: END -> END at line 8282
parser_dispatch_scan_event:10499 (1: 0|1|5)
Next token is token "integer literal" (1.0-1.1: 1)  次の記号は"integer literal"
Shifting token "integer literal" (1.0-1.1: 1)       "integer literal"をシフト

Entering state 41
Stack now 0 2 41
Reducing stack by rule 645 (line 5383):             構文規則645に従って還元を開始
   $1 = token "integer literal" (1.0-1.1: 1)
-> $$ = nterm simple_numeric (1.0-1.1: NODE_LIT)    "integer literal"をsimple_numericに還元

Entering state 120
Stack now 0 2 120
Reducing stack by rule 643 (line 5372):             構文規則643に従って還元を開始
   $1 = nterm simple_numeric (1.0-1.1: NODE_LIT)
-> $$ = nterm numeric (1.0-1.1: NODE_LIT)           simple_numericをnumericに還元

Entering state 119
Stack now 0 2 119
Reducing stack by rule 595 (line 4998):             構文規則119に従って還元を開始
   $1 = nterm numeric (1.0-1.1: NODE_LIT)
-> $$ = nterm literal (1.0-1.1: NODE_LIT)           numericをliteralに還元

Entering state 106
Stack now 0 2 106
Reducing stack by rule 310 (line 3220):             構文規則310に従って還元を開始
   $1 = nterm literal (1.0-1.1: NODE_LIT)
-> $$ = nterm primary (1.0-1.1: NODE_LIT)           literalをprimaryに還元
                                                    構文解析器はこの後適用すべき構文規則を確認するために
                                                    次の記号を必要とする

Entering state 90
Stack now 0 2 90
Reading a token                                     次の記号を読み込む
parser_dispatch_scan_event:9833 (1: 1|1|4)
lex_state: END -> BEG at line 10181
parser_dispatch_scan_event:10499 (1: 2|1|3)
Next token is token '+' (1.2-1.3: )                 次の記号は'+'
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.0-1.1: NODE_LIT)
-> $$ = nterm arg (1.0-1.1: NODE_LIT)               primaryをargに還元

Entering state 88
Stack now 0 2 88
Next token is token '+' (1.2-1.3: )
Shifting token '+' (1.2-1.3: )                      '+'をシフト
                                                    構文解析器はこの後適用すべき構文規則を確認するために
                                                    次の記号を必要とする

Entering state 367
Stack now 0 2 88 367
Reading a token                                     次の記号を読み込む
parser_dispatch_scan_event:9833 (1: 3|1|2)
lex_state: BEG -> END at line 9005
lex_state: END -> END at line 8282
parser_dispatch_scan_event:10499 (1: 4|1|1)
Next token is token "integer literal" (1.4-1.5: 2)  次の記号は"integer literal"
Shifting token "integer literal" (1.4-1.5: 2)

Entering state 41
Stack now 0 2 88 367 41
Reducing stack by rule 645 (line 5383):             構文規則645に従って還元を開始
   $1 = token "integer literal" (1.4-1.5: 2)
-> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)    "integer literal"をsimple_numericに還元

Entering state 120
Stack now 0 2 88 367 120
Reducing stack by rule 643 (line 5372):             構文規則643に従って還元を開始
   $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm numeric (1.4-1.5: NODE_LIT)           simple_numericをnumericに還元

Entering state 119
Stack now 0 2 88 367 119
Reducing stack by rule 595 (line 4998):             構文規則595に従って還元を開始
   $1 = nterm numeric (1.4-1.5: NODE_LIT)
-> $$ = nterm literal (1.4-1.5: NODE_LIT)           numericをliteralに還元

Entering state 106
Stack now 0 2 88 367 106
Reducing stack by rule 310 (line 3220):             構文規則310に従って還元を開始
   $1 = nterm literal (1.4-1.5: NODE_LIT)
-> $$ = nterm primary (1.4-1.5: NODE_LIT)           literalをprimaryに還元
                                                    構文解析器はこの後適用すべき構文規則を確認するために
                                                    次の記号を必要とする

Entering state 90
Stack now 0 2 88 367 90
Reading a token                                     次の記号を読み込む
lex_state: END -> BEG at line 9900
parser_dispatch_scan_event:10499 (1: 5|1|0)
Next token is token '\n' (1.5-1.6: )                次の記号は'\n' (行末)
Reducing stack by rule 263 (line 2906):
   $1 = nterm primary (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.4-1.5: NODE_LIT)               primaryをargに還元

Entering state 602
Stack now 0 2 88 367 602
Next token is token '\n' (1.5-1.6: )
Reducing stack by rule 231 (line 2745):             構文規則231に従って還元を開始
   $1 = nterm arg (1.0-1.1: NODE_LIT)
   $2 = token '+' (1.2-1.3: )
   $3 = nterm arg (1.4-1.5: NODE_LIT)
-> $$ = nterm arg (1.0-1.5: NODE_OPCALL)            arg + argをargに還元

Entering state 88
Stack now 0 2 88
Next token is token '\n' (1.5-1.6: )
Reducing stack by rule 65 (line 2051):              構文規則65に従って還元を開始
   $1 = nterm arg (1.0-1.5: NODE_OPCALL)
-> $$ = nterm expr (1.0-1.5: NODE_OPCALL)           argをexprに還元

Entering state 75
Stack now 0 2 75
Next token is token '\n' (1.5-1.6: )
Reducing stack by rule 37 (line 1853):              構文規則75に従って還元を開始
   $1 = nterm expr (1.0-1.5: NODE_OPCALL)
-> $$ = nterm stmt (1.0-1.5: NODE_OPCALL)           exprをstmtに還元

Entering state 73
Stack now 0 2 73
Next token is token '\n' (1.5-1.6: )
Reducing stack by rule 7 (line 1635):               構文規則73に従って還元を開始
   $1 = nterm stmt (1.0-1.5: NODE_OPCALL)
-> $$ = nterm top_stmt (1.0-1.5: NODE_OPCALL)       exprをtop_stmtに還元

Entering state 72
Stack now 0 2 72
Reducing stack by rule 5 (line 1619):               構文規則72に従って還元を開始
   $1 = nterm top_stmt (1.0-1.5: NODE_OPCALL)
-> $$ = nterm top_stmts (1.0-1.5: NODE_OPCALL)      top_stmtをtop_stmtsに還元
                                                    構文解析器は式を終わらせるために'\n'を必要とする

Entering state 71
Stack now 0 2 71
Next token is token '\n' (1.5-1.6: )
Shifting token '\n' (1.5-1.6: )                     '\n'をシフト

Entering state 310
Stack now 0 2 71 310
Reducing stack by rule 778 (line 6115):             構文規則778に従って還元を開始
   $1 = token '\n' (1.5-1.6: )
-> $$ = nterm term (1.5-1.5: )                      '\n'をtermに還元

Entering state 312
Stack now 0 2 71 312
Reducing stack by rule 779 (line 6122):             構文規則779に従って還元を開始
   $1 = nterm term (1.5-1.5: )
-> $$ = nterm terms (1.5-1.5: )                     termをtermsに還元
                                                    ここで行が完結する

Entering state 313
Stack now 0 2 71 313
Reading a token                                     次の行に進もうとして次の記号を読み込む
Now at end of input.                                次の行は存在しない
Reducing stack by rule 769 (line 6094):             構文規則769に従って還元を開始
   $1 = nterm terms (1.5-1.5: )
-> $$ = nterm opt_terms (1.5-1.5: )                 termsをopt_termsに還元

Entering state 311
Stack now 0 2 71 311
Reducing stack by rule 3 (line 1606):               構文規則3に従って還元を開始
   $1 = nterm top_stmts (1.0-1.5: NODE_OPCALL)
   $2 = nterm opt_terms (1.5-1.5: )
-> $$ = nterm top_compstmt (1.0-1.5: NODE_OPCALL)   top_stmts opt_termsをtop_compstmtに還元

Entering state 70
Stack now 0 2 70
Reducing stack by rule 2 (line 1580):               構文規則2に従って還元を開始
   $1 = nterm $@1 (1.0-1.0: )
   $2 = nterm top_compstmt (1.0-1.5: NODE_OPCALL)
vtable_free:13164: p->lvtbl->args(0x00006000034e9b40)
vtable_free:13165: p->lvtbl->vars(0x00006000034e9b60)
cmdarg_stack(pop): 0 at line 13166
cond_stack(pop): 0 at line 13167
-> $$ = nterm program (1.0-1.5: )                   top_compstmtをprogramに還

Entering state 1
Stack now 0 1
Now at end of input.
Shifting token "end-of-input" (1.6-1.6: )

Entering state 3
Stack now 0 1 3
Stack now 0 1 3
Cleanup: popping token "end-of-input" (1.6-1.6: )
Cleanup: popping nterm program (1.0-1.5: )         正常に入力が終わったことを確認して構文解析を終了
```
