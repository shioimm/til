i = 0
i += 1

# $ ruby -yc parsing+=.rb
#
# Starting parse
#
# Entering state 0
# Stack now 0
# Reducing stack by rule 1 (line 1390):                         program の還元を開始
# lex_state: NONE -> BEG at line 1391
# vtable_alloc:12766: 0x00006000024232e0
# vtable_alloc:12767: 0x0000600002423300
# cmdarg_stack(push): 0 at line 12780                           local_push() cmdarg_stackに0をpush
# cond_stack(push): 0 at line 12781                             local_push() cond_stackに0をpush
# -> $$ = nterm $@1 (1.0-1.0: )
#
# ----- semantic stack -------
#
# ----------------------------
#
# Entering state 2
# Stack now 0 2
# Reading a token                                               トークンを読み込み
# lex_state: BEG -> CMDARG at line 9407                         parse_ident() (parser_yylex() -> default)
# Next token is token "local variable or method" (1.0-1.1: i)   次のトークンはtIDENTIFIER (i)
# Shifting token "local variable or method" (1.0-1.1: i)        -> tIDENTIFIER (i) をシフトし、State 35へ進む
#
# ----- semantic stack -------
# tIDENTIFIER
# ----------------------------
#
# Entering state 35
# Stack now 0 2 35
# Reading a token                                               トークンを読み込み
# lex_state: CMDARG -> BEG at line 9658                         parser_yylex() case '='
# Next token is token '=' (1.2-1.3: )                           次のトークンは'='
# Reducing stack by rule 652 (line 5193):                       -> user_variable (i) を還元 (tIDENTIFIER)
#    $1 = token "local variable or method" (1.0-1.1: i)
# -> $$ = nterm user_variable (1.0-1.1: )
#
# ----- semantic stack -------
# user_variable
# ----------------------------
#
# Entering state 122
# Stack now 0 2 122
# Next token is token '=' (1.2-1.3: )                           次のトークンは'='
# Reducing stack by rule 121 (line 2255):                       -> lhsを還元 (user_variable)
#    $1 = nterm user_variable (1.0-1.1: )
# vtable_add:12867: p->lvtbl->vars(0x0000600002423300), i
# -> $$ = nterm lhs (1.0-1.1: NODE_LASGN)
#
# ----- semantic stack -------
# lhs
# ----------------------------
#
# Entering state 87
# Stack now 0 2 87
# Next token is token '=' (1.2-1.3: )                           次のトークンは'='
# Shifting token '=' (1.2-1.3: )                                -> '=' をシフトし、State 343へ進む
#
# ----- semantic stack -------
# lhs '='
# ----------------------------
#
# Entering state 343
# Stack now 0 2 87 343
# Reducing stack by rule 781 (line 5914):                       none を還元 (空) し、State 577へ進む
# -> $$ = nterm none (1.3-1.3: )
#
# ----- semantic stack -------
# lhs '=' none
# ----------------------------
#
# Entering state 577
# Stack now 0 2 87 343 577
# Reducing stack by rule 270 (line 2739):                       -> lex_ctxt を還元 (none)
#    $1 = nterm none (1.3-1.3: )
# -> $$ = nterm lex_ctxt (1.3-1.3: )
#
# ----- semantic stack -------
# lhs '=' lex_ctxt
# ----------------------------
#
# Entering state 582
# Stack now 0 2 87 343 582
# Reading a token                                               トークンを読み込み
# lex_state: BEG -> END at line 8679                            parse_numeric()
# lex_state: END -> END at line 7973                            set_number_literal()
# Next token is token "integer literal" (1.4-1.5: 0)            次のトークンは tINTEGER (0)
# Shifting token "integer literal" (1.4-1.5: 0)                 -> tINTEGER (0) をシフトし、State 41へ進む
#
# ----- semantic stack -------
# lhs '=' lex_ctxt tINTEGER
# ----------------------------
#
# Entering state 41
# Stack now 0 2 87 343 582 41
# Reducing stack by rule 645 (line 5182):                       -> simple_numeric を還元 (tINTEGER)
#    $1 = token "integer literal" (1.4-1.5: 0)
# -> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt simple_numeric
# ----------------------------
#
# Entering state 120
# Stack now 0 2 87 343 582 120
# Reducing stack by rule 643 (line 5171):                       -> numeric を還元 (simple_numeric)
#    $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm numeric (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt numeric
# ----------------------------
#
# Entering state 119
# Stack now 0 2 87 343 582 119
# Reducing stack by rule 595 (line 4797):                       -> literal を還元 (numeric)
#    $1 = nterm numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm literal (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt literal
# ----------------------------
#
# Entering state 106
# Stack now 0 2 87 343 582 106
# Reducing stack by rule 310 (line 3028):                       -> primary を還元 (literal)
#    $1 = nterm literal (1.4-1.5: NODE_LIT)
# -> $$ = nterm primary (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt primary
# ----------------------------
#
# Entering state 90
# Stack now 0 2 87 343 582 90
# Reading a token                                               トークンを読み込み
# lex_state: END -> BEG at line 9565                            parser_yylex() case '-1'
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Reducing stack by rule 263 (line 2716):                       -> arg を還元 (primary)
#    $1 = nterm primary (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt arg
# ----------------------------
#
# Entering state 772
# Stack now 0 2 87 343 582 772
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Reducing stack by rule 276 (line 2773):                       -> arg_rhs を還元 (arg   %prec tOP_ASGN)
#    $1 = nterm arg (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)
#
# ----- semantic stack -------
# lhs '=' lex_ctxt arg_rhs
# ----------------------------
#
# Entering state 774
# Stack now 0 2 87 343 582 774
# Reducing stack by rule 216 (line 2439):                       -> arg を還元 (lhs '=' lex_ctxt arg_rhs)
#    $1 = nterm lhs (1.0-1.1: NODE_LASGN)
#    $2 = token '=' (1.2-1.3: )
#    $3 = nterm lex_ctxt (1.3-1.3: )
#    $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.0-1.5: NODE_LASGN)
#
# ----- semantic stack -------
# arg
# ----------------------------
#
# Entering state 88
# Stack now 0 2 88
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Reducing stack by rule 65 (line 1861):                        -> expr を還元 (arg %prec tLBRACE_ARG)
#    $1 = nterm arg (1.0-1.5: NODE_LASGN)
# -> $$ = nterm expr (1.0-1.5: NODE_LASGN)
#
# ----- semantic stack -------
# expr
# ----------------------------
#
# Entering state 75
# Stack now 0 2 75
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Reducing stack by rule 37 (line 1663):                        -> stmt を還元 (expr)
#    $1 = nterm expr (1.0-1.5: NODE_LASGN)
# -> $$ = nterm stmt (1.0-1.5: NODE_LASGN)
#
# ----- semantic stack -------
# stmt
# ----------------------------
#
# Entering state 73
# Stack now 0 2 73
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Reducing stack by rule 7 (line 1445):                         -> top_stmt を還元 (stmt)
#    $1 = nterm stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmt
# ----------------------------
#
# Entering state 72
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1429):                         top_stmts を還元 (top_stmt)
#    $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# ----------------------------
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (1.5-1.5: )                          次のトークンは '\n'
# Shifting token '\n' (1.5-1.5: )                               '\n' をシフトし、State 310へ進む
#
# ----- semantic stack -------
# top_stmts
# '\n'
# ----------------------------
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 5906):                       -> term を還元 ('\n') し、State 312へ進む
#    $1 = token '\n' (1.5-1.5: )
# -> $$ = nterm term (1.5-1.5: )
#
# ----- semantic stack -------
# top_stmts
# term
# ----------------------------
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 5909):                       -> terms を還元 (term)
#    $1 = nterm term (1.5-1.5: )
# -> $$ = nterm terms (1.5-1.5: )
#
# ----- semantic stack -------
# top_stmts
# terms
# ----------------------------
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token                                               トークンを読み込み
# lex_state: BEG -> CMDARG at line 9407
# lex_state: CMDARG -> END|LABEL at line 9425                   parse_ident()
# Next token is token "local variable or method" (2.0-2.1: i)   次のトークンは tIDENTIFIER (i)
# Shifting token "local variable or method" (2.0-2.1: i)        -> tIDENTIFIER (i) をシフトし、State 35へ進む
#
# ----- semantic stack -------
# top_stmts
# terms
# tIDENTIFIER
# ----------------------------
#
# Entering state 35
# Stack now 0 2 71 313 35
# Reading a token                                               トークンを読み込み
# lex_state: END|LABEL -> BEG at line 9835                      parser_yylex() case '='
# Next token is token "operator-assignment" (2.2-2.4: +)        次のトークンは tOP_ASGN (+=)
# Reducing stack by rule 652 (line 5193):                       -> user_variable を還元 (tIDENTIFIER)
#    $1 = token "local variable or method" (2.0-2.1: i)
# -> $$ = nterm user_variable (2.0-2.1: )
#
# ----- semantic stack -------
# top_stmts
# terms
# user_variable
# ----------------------------
#
# Entering state 122
# Stack now 0 2 71 313 122
# Next token is token "operator-assignment" (2.2-2.4: +)        次のトークンは tOP_ASGN (+=)
# Reducing stack by rule 664 (line 5229):                       -> var_lhs を還元 (user_variable)
#    $1 = nterm user_variable (2.0-2.1: )
# -> $$ = nterm var_lhs (2.0-2.1: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs
# ----------------------------
#
# Entering state 125
# Stack now 0 2 71 313 125
# Next token is token "operator-assignment" (2.2-2.4: +)        次のトークンは tOP_ASGN (+=)
# Shifting token "operator-assignment" (2.2-2.4: +)             -> tOP_ASGN (+=) をシフトし、State 429へ進む
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs
# ----------------------------
#
# Entering state 429
# Stack now 0 2 71 313 125 429
# Reducing stack by rule 781 (line 5914):                       -> none を還元 (空)
# -> $$ = nterm none (2.4-2.4: )
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs none
# ----------------------------
#
# Entering state 577
# Stack now 0 2 71 313 125 429 577
# Reducing stack by rule 270 (line 2739):                       -> lex_ctxt を還元 (none)
#    $1 = nterm none (2.4-2.4: )
# -> $$ = nterm lex_ctxt (2.4-2.4: )
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt
# ----------------------------
#
# Entering state 658
# Stack now 0 2 71 313 125 429 658
# Reading a token                                               トークンを読み込み
# lex_state: BEG -> END at line 8679                            parse_numeric()
# lex_state: END -> END at line 7973                            set_number_literal()
# Next token is token "integer literal" (2.5-2.6: 1)            次のトークンは tINTEGER (1)
# Shifting token "integer literal" (2.5-2.6: 1)                 -> tINTEGER (1) をシフト
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt tINTEGER
# ----------------------------
#
# Entering state 41
# Stack now 0 2 71 313 125 429 658 41
# Reducing stack by rule 645 (line 5182):                       -> simple_numeric を還元 (tINTEGER)
#    $1 = token "integer literal" (2.5-2.6: 1)
# -> $$ = nterm simple_numeric (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt simple_numeric
# ----------------------------
#
# Entering state 120
# Stack now 0 2 71 313 125 429 658 120
# Reducing stack by rule 643 (line 5171):                       -> numeric を還元 (simple_numeric)
#    $1 = nterm simple_numeric (2.5-2.6: NODE_LIT)
# -> $$ = nterm numeric (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt numeric
# ----------------------------
#
# Entering state 119
# Stack now 0 2 71 313 125 429 658 119
# Reducing stack by rule 595 (line 4797):                       -> literal を還元 (numeric)
#    $1 = nterm numeric (2.5-2.6: NODE_LIT)
# -> $$ = nterm literal (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt literal
# ----------------------------
#
# Entering state 106
# Stack now 0 2 71 313 125 429 658 106
# Reducing stack by rule 310 (line 3028):                       -> primary を還元 (literal)
#    $1 = nterm literal (2.5-2.6: NODE_LIT)
# -> $$ = nterm primary (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt primary
# ----------------------------
#
# Entering state 90
# Stack now 0 2 71 313 125 429 658 90
# Reading a token                                               トークンを読み込み
# lex_state: END -> BEG at line 9565                            parser_yylex() case '-1'
# Next token is token '\n' (2.6-2.6: )                          次のトークンは '\n'
# Reducing stack by rule 263 (line 2716):                       -> arg を還元 (primary)
#    $1 = nterm primary (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs lex_ctxt arg
# ----------------------------
#
# Entering state 832
# Stack now 0 2 71 313 125 429 658 832
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 276 (line 2773):                       arg_rhs を還元 (arg   %prec tOP_ASGN)
#    $1 = nterm arg (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg_rhs (2.5-2.6: NODE_LIT)
#
# Entering state 833
# Stack now 0 2 71 313 125 429 658 833
# Reducing stack by rule 217 (line 2446):                       arg を還元 (var_lhs tOP_ASGN lex_ctxt arg_rhs)
#    $1 = nterm var_lhs (2.0-2.1: NODE_LASGN)
#    $2 = token "operator-assignment" (2.2-2.4: +)
#    $3 = nterm lex_ctxt (2.4-2.4: )
#    $4 = nterm arg_rhs (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg (2.0-2.6: NODE_LASGN)
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 65 (line 1861):                        expr を還元 (arg %prec tLBRACE_ARG)
#    $1 = nterm arg (2.0-2.6: NODE_LASGN)
# -> $$ = nterm expr (2.0-2.6: NODE_LASGN)
#
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 37 (line 1663):                        stmt を還元 (expr)
#    $1 = nterm expr (2.0-2.6: NODE_LASGN)
# -> $$ = nterm stmt (2.0-2.6: NODE_LASGN)
#
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (2.6-2.6: )
# Reducing stack by rule 7 (line 1445):                         top_stmt を還元 (stmt)
#    $1 = nterm stmt (2.0-2.6: NODE_LASGN)
# -> $$ = nterm top_stmt (2.0-2.6: NODE_LASGN)
#
# Entering state 520
# Stack now 0 2 71 313 520
# Reducing stack by rule 6 (line 1436):                         top_stmts を還元 (top_stmts terms top_stmt)
#    $1 = nterm top_stmts (1.0-1.5: NODE_LASGN)
#    $2 = nterm terms (1.5-1.5: )
#    $3 = nterm top_stmt (2.0-2.6: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-2.6: NODE_BLOCK)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (2.6-2.6: )
# Shifting token '\n' (2.6-2.6: )                               '\n' をシフト
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 5906):                       term を還元 ('\n')
#    $1 = token '\n' (2.6-2.6: )
# -> $$ = nterm term (2.6-2.6: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 5909):                       terms を還元 (term)
#    $1 = nterm term (2.6-2.6: )
# -> $$ = nterm terms (2.6-2.6: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# Now at end of input.
# Reducing stack by rule 769 (line 5885):                       opt_terms を還元 (terms)
#    $1 = nterm terms (2.6-2.6: )
# -> $$ = nterm opt_terms (2.6-2.6: )
#
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1416):                         top_compstmt を還元 (top_stmts opt_terms)
#    $1 = nterm top_stmts (1.0-2.6: NODE_BLOCK)
#    $2 = nterm opt_terms (2.6-2.6: )
# -> $$ = nterm top_compstmt (1.0-2.6: NODE_BLOCK)
#
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1390):                         program の還元を終了
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-2.6: NODE_BLOCK)
# vtable_free:12800: p->lvtbl->args(0x00006000024232e0)
# vtable_free:12801: p->lvtbl->vars(0x0000600002423300)
# cmdarg_stack(pop): 0 at line 12802                            local_pop() cmdarg_stackをpop
# cond_stack(pop): 0 at line 12803                              local_pop() cond_stackをpop
# -> $$ = nterm program (1.0-2.6: )
#
# Entering state 1
# Stack now 0 1
# Now at end of input.
# Shifting token "end-of-input" (2.6-2.6: )                     END_OF_INPUT をシフト
#
# Entering state 3
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (2.6-2.6: )
# Cleanup: popping nterm program (1.0-2.6: )
# Syntax OK
