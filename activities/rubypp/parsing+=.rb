i = 0
i += 1

# $ ruby -yc parsing+=.rb
#
# Starting parse
#
# Entering state 0                                            $@1への還元を開始
# Stack now 0
# Reducing stack by rule 1 (line 1390):                       -> $@1: -> State 2
# lex_state: NONE -> BEG at line 1391
# vtable_alloc:12766: 0x00006000024232e0
# vtable_alloc:12767: 0x0000600002423300
# cmdarg_stack(push): 0 at line 12780                         local_push() cmdarg_stackに0をpush
# cond_stack(push): 0 at line 12781                           local_push() cond_stackに0をpush
# -> $$ = nterm $@1 (1.0-1.0: )                               $@1への還元を完了
#
# ----- semantic stack -------
#
# ----------------------------
#
# Entering state 2                                            programへの還元を開始 (-> top_compstmtが必要)
# Stack now 0 2
# Reading a token                                             トークンを読み込み
# lex_state: BEG -> CMDARG at line 9407                       parse_ident() (parser_yylex() -> default)
# Next token is token "local variable or method" (1.0-1.1: i) 次のトークンはtIDENTIFIER (i)
# Shifting token "local variable or method" (1.0-1.1: i)      -> (tIDENTIFIER) トークンをシフト -> State 35
#
# ----- semantic stack -------
# tIDENTIFIER
# ----------------------------
#
# Entering state 35                                           user_variableへの還元を開始 (-> '='が必要)
# Stack now 0 2 35
# Reading a token                                             トークンを読み込み
# lex_state: CMDARG -> BEG at line 9658                       parser_yylex() case '='
# Next token is token '=' (1.2-1.3: )                         次のトークンは'='
# Reducing stack by rule 652 (line 5193):                     -> ('=') user_variable (i) : tIDENTIFIER
#    $1 = token "local variable or method" (1.0-1.1: i)
# -> $$ = nterm user_variable (1.0-1.1: )                     user_variableへの還元を完了
#
# ----- semantic stack -------
# user_variable
# ----------------------------
#
# Entering state 122                                          lhsへの還元を開始 (-> '='が必要)
# Stack now 0 2 122
# Next token is token '=' (1.2-1.3: )                         次のトークンは'='
# Reducing stack by rule 121 (line 2255):                     -> ('=') lhs : user_variable
#    $1 = nterm user_variable (1.0-1.1: )
# vtable_add:12867: p->lvtbl->vars(0x0000600002423300), i
# -> $$ = nterm lhs (1.0-1.1: NODE_LASGN)                     lhsへの還元を完了
#
# ----- semantic stack -------
# lhs
# ----------------------------
#
# Entering state 87                                           stmtへの還元を開始 (-> '=' lex_ctxt mrhsが必要)
# Stack now 0 2 87
# Next token is token '=' (1.2-1.3: )                         次のトークンは'='
# Shifting token '=' (1.2-1.3: )                              -> ('=') トークンをシフト -> State 343
#
# ----- semantic stack -------
# lhs '='
# ----------------------------
#
# Entering state 343                                          stmtへの還元を開始 (-> lex_ctxt mrhsが必要)
# Stack now 0 2 87 343
# Reducing stack by rule 781 (line 5914):                     -> ($default) noneを還元 / (none) -> State 577
# -> $$ = nterm none (1.3-1.3: )                              noneへの還元を完了
#
# ----- semantic stack -------
# lhs '=' none
# ----------------------------
#
# Entering state 577                                          lex_ctxtへの還元を開始
# Stack now 0 2 87 343 577
# Reducing stack by rule 270 (line 2739):                     -> ($default) lex_ctxt : none
#    $1 = nterm none (1.3-1.3: )
# -> $$ = nterm lex_ctxt (1.3-1.3: )                          lex_ctxtへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt
# ----------------------------
#
# Entering state 582                                          stmtへの還元を開始 (-> mrhsが必要)
# Stack now 0 2 87 343 582
# Reading a token                                             トークンを読み込み
# lex_state: BEG -> END at line 8679                          parse_numeric()
# lex_state: END -> END at line 7973                          set_number_literal()
# Next token is token "integer literal" (1.4-1.5: 0)          次のトークンはtINTEGER (0)
# Shifting token "integer literal" (1.4-1.5: 0)               -> (tINTEGER) トークンをシフト -> State 41
#
# ----- semantic stack -------
# lhs '=' lex_ctxt tINTEGER
# ----------------------------
#
# Entering state 41                                           simple_numericへの還元を開始
# Stack now 0 2 87 343 582 41
# Reducing stack by rule 645 (line 5182):                     -> ($default) tINTEGER : simple_numeric
#    $1 = token "integer literal" (1.4-1.5: 0)
# -> $$ = nterm simple_numeric (1.4-1.5: NODE_LIT)            simple_numericへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt simple_numeric
# ----------------------------
#
# Entering state 120                                          numericへの還元を開始
# Stack now 0 2 87 343 582 120
# Reducing stack by rule 643 (line 5171):                     -> ($default) numeric : simple_numeric
#    $1 = nterm simple_numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm numeric (1.4-1.5: NODE_LIT)                   numericへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt numeric
# ----------------------------
#
# Entering state 119                                          literalへの還元を開始
# Stack now 0 2 87 343 582 119
# Reducing stack by rule 595 (line 4797):                     -> ($default) literal : numeric
#    $1 = nterm numeric (1.4-1.5: NODE_LIT)
# -> $$ = nterm literal (1.4-1.5: NODE_LIT)                   literalへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt literal
# ----------------------------
#
# Entering state 106                                          primaryへの還元を開始
# Stack now 0 2 87 343 582 106
# Reducing stack by rule 310 (line 3028):                     -> ($default) primary : literal
#    $1 = nterm literal (1.4-1.5: NODE_LIT)
# -> $$ = nterm primary (1.4-1.5: NODE_LIT)                   primaryへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt primary
# ----------------------------
#
# Entering state 90                                           argへの還元を開始 (-> '\n'が必要)
# Stack now 0 2 87 343 582 90
# Reading a token                                             トークンを読み込み
# lex_state: END -> BEG at line 9565                          parser_yylex() case '-1'
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Reducing stack by rule 263 (line 2716):                     -> ($default) arg : primary
#    $1 = nterm primary (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.4-1.5: NODE_LIT)                       argへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt arg
# ----------------------------
#
# Entering state 772                                          arg_rhsへの還元を開始 (-> '\n'が必要)
# Stack now 0 2 87 343 582 772
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Reducing stack by rule 276 (line 2773):                     -> ($default) arg_rhs : arg %prec tOP_ASGN
#    $1 = nterm arg (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg_rhs (1.4-1.5: NODE_LIT)                   arg_rhsへの還元を完了
#
# ----- semantic stack -------
# lhs '=' lex_ctxt arg_rhs
# ----------------------------
#
# Entering state 774                                          argへの還元を開始
# Stack now 0 2 87 343 582 774
# Reducing stack by rule 216 (line 2439):                     -> ($default) arg : lhs '=' lex_ctxt arg_rhs
#    $1 = nterm lhs (1.0-1.1: NODE_LASGN)
#    $2 = token '=' (1.2-1.3: )
#    $3 = nterm lex_ctxt (1.3-1.3: )
#    $4 = nterm arg_rhs (1.4-1.5: NODE_LIT)
# -> $$ = nterm arg (1.0-1.5: NODE_LASGN)                     argへの還元を完了
#
# ----- semantic stack -------
# arg
# ----------------------------
#
# Entering state 88                                           exprへの還元を開始 (-> '\n'が必要)
# Stack now 0 2 88
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Reducing stack by rule 65 (line 1861):                      -> ($default) expr : arg %prec tLBRACE_ARG
#    $1 = nterm arg (1.0-1.5: NODE_LASGN)
# -> $$ = nterm expr (1.0-1.5: NODE_LASGN)                    exprへの還元を完了
#
# ----- semantic stack -------
# expr
# ----------------------------
#
# Entering state 75                                           stmtへの還元を開始 (-> '\n'が必要)
# Stack now 0 2 75
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Reducing stack by rule 37 (line 1663):                      -> ($default) stmt : expr
#    $1 = nterm expr (1.0-1.5: NODE_LASGN)
# -> $$ = nterm stmt (1.0-1.5: NODE_LASGN)                    stmtへの還元を完了
#
# ----- semantic stack -------
# stmt
# ----------------------------
#
# Entering state 73                                           top_stmtへの還元を開始 (-> '\n'が必要)
# Stack now 0 2 73
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Reducing stack by rule 7 (line 1445):                       -> ($default) top_stmt : stmt
#    $1 = nterm stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmt (1.0-1.5: NODE_LASGN)                top_stmtへの還元を完了
#
# ----- semantic stack -------
# top_stmt
# ----------------------------
#
# Entering state 72                                           top_stmtsへの還元を開始
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1429):                       -> ($default) top_stmts : top_stmt
#    $1 = nterm top_stmt (1.0-1.5: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-1.5: NODE_LASGN)               top_stmtsへの還元を完了
#
# ----- semantic stack -------
# top_stmts
# ----------------------------
#
# Entering state 71                                           termへの還元を開始
# Stack now 0 2 71
# Next token is token '\n' (1.5-1.5: )                        次のトークンは'\n'
# Shifting token '\n' (1.5-1.5: )                             -> ('\n') トークンをシフト -> State 310
#
# ----- semantic stack -------
# top_stmts '\n'
# ----------------------------
#
# Entering state 310                                          termへの還元を開始
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 5906):                     -> ($default) term : '\n' -> State 312
#    $1 = token '\n' (1.5-1.5: )
# -> $$ = nterm term (1.5-1.5: )                              termへの還元を完了
#
# ----- semantic stack -------
# top_stmts term
# ----------------------------
#
# Entering state 312                                          termsへの還元を開始
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 5909):                     -> ($default) terms : term
#    $1 = nterm term (1.5-1.5: )
# -> $$ = nterm terms (1.5-1.5: )                             termsへの還元を完了
#
# ----- semantic stack -------
# top_stmts terms
# ----------------------------
#
# Entering state 313                                          top_stmtsへの還元を開始 (-> top_stmtが必要)
# Stack now 0 2 71 313
# Reading a token                                             トークンを読み込み
# lex_state: BEG -> CMDARG at line 9407
# lex_state: CMDARG -> END|LABEL at line 9425                 parse_ident()
# Next token is token "local variable or method" (2.0-2.1: i) 次のトークンはtIDENTIFIER (i)
# Shifting token "local variable or method" (2.0-2.1: i)      -> (tIDENTIFIER) トークンをシフト -> State 35
#
# ----- semantic stack -------
# top_stmts terms tIDENTIFIER
# ----------------------------
#
# Entering state 35                                           --WIP--
# Stack now 0 2 71 313 35
# Reading a token                                             トークンを読み込み
# lex_state: END|LABEL -> BEG at line 9835                    parser_yylex() case '='
# Next token is token "operator-assignment" (2.2-2.4: +)      次のトークンはtOP_ASGN (+=)
# Reducing stack by rule 652 (line 5193):                     -> user_variableを還元 (tIDENTIFIER)
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
# Next token is token "operator-assignment" (2.2-2.4: +)      次のトークンはtOP_ASGN (+=)
# Reducing stack by rule 664 (line 5229):                     -> var_lhsを還元 (user_variable)
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
# Next token is token "operator-assignment" (2.2-2.4: +)      次のトークンはtOP_ASGN (+=)
# Shifting token "operator-assignment" (2.2-2.4: +)           -> tOP_ASGN (+=) をシフト
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN
# ----------------------------
#
# Entering state 429
# Stack now 0 2 71 313 125 429
# Reducing stack by rule 781 (line 5914):                     -> noneを還元 (空)
# -> $$ = nterm none (2.4-2.4: )
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN none
# ----------------------------
#
# Entering state 577
# Stack now 0 2 71 313 125 429 577
# Reducing stack by rule 270 (line 2739):                     -> lex_ctxtを還元 (none)
#    $1 = nterm none (2.4-2.4: )
# -> $$ = nterm lex_ctxt (2.4-2.4: )
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt
# ----------------------------
#
# Entering state 658
# Stack now 0 2 71 313 125 429 658
# Reading a token                                             トークンを読み込み
# lex_state: BEG -> END at line 8679                          parse_numeric()
# lex_state: END -> END at line 7973                          set_number_literal()
# Next token is token "integer literal" (2.5-2.6: 1)          次のトークンはtINTEGER (1)
# Shifting token "integer literal" (2.5-2.6: 1)               -> tINTEGER (1) をシフト
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt tINTEGER
# ----------------------------
#
# Entering state 41
# Stack now 0 2 71 313 125 429 658 41
# Reducing stack by rule 645 (line 5182):                     -> simple_numericを還元 (tINTEGER)
#    $1 = token "integer literal" (2.5-2.6: 1)
# -> $$ = nterm simple_numeric (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt simple_numeric
# ----------------------------
#
# Entering state 120
# Stack now 0 2 71 313 125 429 658 120
# Reducing stack by rule 643 (line 5171):                     -> numericを還元 (simple_numeric)
#    $1 = nterm simple_numeric (2.5-2.6: NODE_LIT)
# -> $$ = nterm numeric (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt numeric
# ----------------------------
#
# Entering state 119
# Stack now 0 2 71 313 125 429 658 119
# Reducing stack by rule 595 (line 4797):                     -> literalを還元 (numeric)
#    $1 = nterm numeric (2.5-2.6: NODE_LIT)
# -> $$ = nterm literal (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt literal
# ----------------------------
#
# Entering state 106
# Stack now 0 2 71 313 125 429 658 106
# Reducing stack by rule 310 (line 3028):                     -> primaryを還元 (literal)
#    $1 = nterm literal (2.5-2.6: NODE_LIT)
# -> $$ = nterm primary (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt primary
# ----------------------------
#
# Entering state 90
# Stack now 0 2 71 313 125 429 658 90
# Reading a token                                             トークンを読み込み
# lex_state: END -> BEG at line 9565                          parser_yylex() case '-1'
# Next token is token '\n' (2.6-2.6: )                        次のトークンは '\n'
# Reducing stack by rule 263 (line 2716):                     -> argを還元 (primary)
#    $1 = nterm primary (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt arg
# ----------------------------
#
# Entering state 832
# Stack now 0 2 71 313 125 429 658 832
# Next token is token '\n' (2.6-2.6: )                        次のトークンは'\n'
# Reducing stack by rule 276 (line 2773):                     -> arg_rhsを還元 (arg   %prec tOP_ASGN)
#    $1 = nterm arg (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg_rhs (2.5-2.6: NODE_LIT)
#
# ----- semantic stack -------
# top_stmts
# terms
# var_lhs tOP_ASGN lex_ctxt arg_rhs
# ----------------------------
#
# Entering state 833
# Stack now 0 2 71 313 125 429 658 833
# Reducing stack by rule 217 (line 2446):                     -> argを還元 (var_lhs tOP_ASGN lex_ctxt arg_rhs)
#    $1 = nterm var_lhs (2.0-2.1: NODE_LASGN)
#    $2 = token "operator-assignment" (2.2-2.4: +)
#    $3 = nterm lex_ctxt (2.4-2.4: )
#    $4 = nterm arg_rhs (2.5-2.6: NODE_LIT)
# -> $$ = nterm arg (2.0-2.6: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# terms
# arg
# ----------------------------
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '\n' (2.6-2.6: )                        次のトークンは'\n'
# Reducing stack by rule 65 (line 1861):                      -> exprを還元 (arg %prec tLBRACE_ARG)
#    $1 = nterm arg (2.0-2.6: NODE_LASGN)
# -> $$ = nterm expr (2.0-2.6: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# terms
# expr
# ----------------------------
#
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (2.6-2.6: )                        次のトークンは'\n'
# Reducing stack by rule 37 (line 1663):                      -> stmtを還元 (expr)
#    $1 = nterm expr (2.0-2.6: NODE_LASGN)
# -> $$ = nterm stmt (2.0-2.6: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# terms
# stmt
# ----------------------------
#
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (2.6-2.6: )                        次のトークンは'\n'
# Reducing stack by rule 7 (line 1445):                       -> top_stmtを還元 (stmt)
#    $1 = nterm stmt (2.0-2.6: NODE_LASGN)
# -> $$ = nterm top_stmt (2.0-2.6: NODE_LASGN)
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmt
# ----------------------------
#
# Entering state 520
# Stack now 0 2 71 313 520
# Reducing stack by rule 6 (line 1436):                       -> top_stmtsを還元 (top_stmts terms top_stmt)
#    $1 = nterm top_stmts (1.0-1.5: NODE_LASGN)
#    $2 = nterm terms (1.5-1.5: )
#    $3 = nterm top_stmt (2.0-2.6: NODE_LASGN)
# -> $$ = nterm top_stmts (1.0-2.6: NODE_BLOCK)
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmts
# ----------------------------
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (2.6-2.6: )
# Shifting token '\n' (2.6-2.6: )                             '\n'をシフト
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmts
# '\n'
# ----------------------------
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 5906):                     -> termを還元 ('\n')
#    $1 = token '\n' (2.6-2.6: )
# -> $$ = nterm term (2.6-2.6: )
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmts
# term
# ----------------------------
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 5909):                     -> termsを還元 (term)
#    $1 = nterm term (2.6-2.6: )
# -> $$ = nterm terms (2.6-2.6: )
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmts terms
# ----------------------------
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token                                             トークンを読み込み
# Now at end of input.                                        インプットなし
# Reducing stack by rule 769 (line 5885):                     -> opt_termsを還元 (terms)
#    $1 = nterm terms (2.6-2.6: )
# -> $$ = nterm opt_terms (2.6-2.6: )
#
# ----- semantic stack -------
# top_stmts
# terms
# top_stmts opt_terms
# ----------------------------
#
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1416):                       -> top_compstmtを還元 (top_stmts opt_terms)
#    $1 = nterm top_stmts (1.0-2.6: NODE_BLOCK)
#    $2 = nterm opt_terms (2.6-2.6: )
# -> $$ = nterm top_compstmt (1.0-2.6: NODE_BLOCK)
#
# ----- semantic stack -------
# top_stmts
# terms
# top_compstmt
# ----------------------------
#
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1390):                       -> programを還元
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-2.6: NODE_BLOCK)
# vtable_free:12800: p->lvtbl->args(0x00006000024232e0)
# vtable_free:12801: p->lvtbl->vars(0x0000600002423300)
# cmdarg_stack(pop): 0 at line 12802                          local_pop() cmdarg_stackをpop
# cond_stack(pop): 0 at line 12803                            local_pop() cond_stackをpop
# -> $$ = nterm program (1.0-2.6: )
#
# ----- semantic stack -------
# top_stmts
# terms
# program
# ----------------------------
#
# Entering state 1                                            $acceptへの還元を開始
# Stack now 0 1
# Now at end of input.                                        インプットなし
# Shifting token "end-of-input" (2.6-2.6: )                   END_OF_INPUTをシフト
#
# ----- semantic stack -------
# top_stmts
# terms
# program END_OF_INPUT
# ----------------------------
#
# Entering state 3                                            $acceptへ還元
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (2.6-2.6: )
# Cleanup: popping nterm program (1.0-2.6: )
# Syntax OK
#
# ----- semantic stack -------
# top_stmts
# terms
# $accept
# ----------------------------
