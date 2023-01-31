class Foo
  def foo
    bar
  end

  def bar
  end
end

Foo.new.foo

# add_delayed_token:7062 (0: 0|0|0)
# Starting parse
#
# Entering state 0
# Stack now 0
# Reducing stack by rule 1 (line 1580):
# lex_state: NONE -> BEG at line 1581
# vtable_alloc:13130: 0x000060000215ed80
# vtable_alloc:13131: 0x000060000215eda0
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm $@1 (1.0-1.0: )
#
# Entering state 2
# Stack now 0 2
# Reading a token
# lex_state: BEG -> CLASS at line 9707
# parser_dispatch_scan_event:10499 (1: 0|5|5)
# Next token is token "`class'" (1.0-1.5: )
# Shifting token "`class'" (1.0-1.5: )
#
# Entering state 5
# Stack now 0 2 5
# Reducing stack by rule 376 (line 3701):
#    $1 = token "`class'" (1.0-1.5: )
# -> $$ = nterm k_class (1.0-1.5: )
#
# Entering state 99
# Stack now 0 2 99
# Reading a token
# parser_dispatch_scan_event:9833 (1: 5|1|4)
# lex_state: CLASS -> ARG at line 9736
# parser_dispatch_scan_event:10499 (1: 6|3|1)
# Next token is token "constant" (1.6-1.9: Foo)
# Shifting token "constant" (1.6-1.9: Foo)
#
# Entering state 399
# Stack now 0 2 99 399
# Reading a token
# add_delayed_token:7062 (1: 9|1|0)
# lex_state: ARG -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (1: 10|0|0)
# Next token is token '\n' (1.9-1.10: )
# Reducing stack by rule 131 (line 2519):
#    $1 = token "constant" (1.6-1.9: Foo)
# -> $$ = nterm cname (1.6-1.9: )
#
# Entering state 402
# Stack now 0 2 99 402
# Reducing stack by rule 133 (line 2529):
#    $1 = nterm cname (1.6-1.9: )
# -> $$ = nterm cpath (1.6-1.9: NODE_COLON2)
#
# Entering state 403
# Stack now 0 2 99 403
# Next token is token '\n' (1.9-1.10: )
# Reducing stack by rule 670 (line 5460):
# -> $$ = nterm superclass (1.9-1.9: )
#
# Entering state 646
# Stack now 0 2 99 403 646
# Reducing stack by rule 354 (line 3487):
# vtable_alloc:13130: 0x000060000215efc0
# vtable_alloc:13131: 0x000060000215efe0
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm $@21 (1.9-1.9: )
#
# Entering state 821
# Stack now 0 2 99 403 646 821
# Next token is token '\n' (1.9-1.10: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (1.9-1.9: )
#
# Entering state 270
# Stack now 0 2 99 403 646 821 270
# Reducing stack by rule 14 (line 1681):
#    $1 = nterm none (1.9-1.9: )
# -> $$ = nterm stmts (1.9-1.9: NODE_BEGIN)
#
# Entering state 265
# Stack now 0 2 99 403 646 821 265
# Next token is token '\n' (1.9-1.10: )
# Shifting token '\n' (1.9-1.10: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (1.9-1.10: )
# -> $$ = nterm term (1.9-1.9: )
#
# Entering state 312
# Stack now 0 2 99 403 646 821 265 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (1.9-1.9: )
# -> $$ = nterm terms (1.9-1.9: )
# Entering state 481
#
# Stack now 0 2 99 403 646 821 265 481
# Reading a token
# add_delayed_token:7062 (1: 10|0|0)
# parser_dispatch_scan_event:9833 (2: 0|2|8)
# lex_state: BEG -> FNAME at line 9707
# parser_dispatch_scan_event:10499 (2: 2|3|5)
# Next token is token "`def'" (2.2-2.5: )
# Shifting token "`def'" (2.2-2.5: )
#
# Entering state 7
# Stack now 0 2 99 403 646 821 265 481 7
# Reducing stack by rule 378 (line 3721):
#    $1 = token "`def'" (2.2-2.5: )
# -> $$ = nterm k_def (2.2-2.5: )
#
# Entering state 101
# Stack now 0 2 99 403 646 821 265 481 101
# Reading a token
# parser_dispatch_scan_event:9833 (2: 5|1|4)
# lex_state: FNAME -> ENDFN at line 9740
# parser_dispatch_scan_event:10499 (2: 6|3|1)
# Next token is token "local variable or method" (2.6-2.9: foo)
# Shifting token "local variable or method" (2.6-2.9: foo)
#
# Entering state 416
# Stack now 0 2 99 403 646 821 265 481 101 416
# Reading a token
# add_delayed_token:7062 (2: 9|1|0)
# parser_dispatch_scan_event:9874 (3: 0|4|8)
# parser_dispatch_scan_event:9848 (3: 4|8|0)
# add_delayed_token:7062 (3: 12|0|0)
# parser_dispatch_scan_event:9874 (4: 0|4|8)
# parser_dispatch_scan_event:9848 (4: 4|8|0)
# add_delayed_token:7062 (4: 12|0|0)
# parser_dispatch_scan_event:9874 (5: 0|4|6)
# parser_dispatch_scan_event:9848 (5: 4|6|0)
# add_delayed_token:7062 (5: 10|0|0)
# lex_state: ENDFN -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (5: 8|0|0)
# Next token is token '\n' (2.9-2.10: )
# Reducing stack by rule 135 (line 2545):
#    $1 = token "local variable or method" (2.6-2.9: foo)
# -> $$ = nterm fname (2.6-2.9: )
# 
# Entering state 420
# Stack now 0 2 99 403 646 821 265 481 101 420
# Reducing stack by rule 66 (line 2054):
#    $1 = nterm fname (2.6-2.9: )
# vtable_alloc:13130: 0x000060000215f1c0
# vtable_alloc:13131: 0x000060000215f1e0
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm def_name (2.6-2.9: NODE_SELF)
#
# Entering state 419
# Stack now 0 2 99 403 646 821 265 481 101 419
# Reducing stack by rule 67 (line 2071):
#    $1 = nterm k_def (2.2-2.5: )
#    $2 = nterm def_name (2.6-2.9: NODE_SELF)
# -> $$ = nterm defn_head (2.2-2.9: NODE_DEFN)
#
# Entering state 76
# Stack now 0 2 99 403 646 821 265 481 76
# Next token is token '\n' (2.9-2.10: )
# Reducing stack by rule 675 (line 5490):
# lex_state: BEG -> BEG|LABEL at line 5494
# -> $$ = nterm @50 (2.9-2.9: )
#
# Entering state 325
# Stack now 0 2 99 403 646 821 265 481 76 325
# Next token is token '\n' (2.9-2.10: )
# Reducing stack by rule 698 (line 5599):
# -> $$ = nterm f_args (2.9-2.9: NODE_ARGS)
#
# Entering state 566
# Stack now 0 2 99 403 646 821 265 481 76 325 566
# Next token is token '\n' (2.9-2.10: )
# Shifting token '\n' (2.9-2.10: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 481 76 325 566 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (2.9-2.10: )
# -> $$ = nterm term (2.9-2.9: )
#
# Entering state 747
# Stack now 0 2 99 403 646 821 265 481 76 325 566 747
# Reducing stack by rule 676 (line 5490):
#    $1 = nterm @50 (2.9-2.9: )
#    $2 = nterm f_args (2.9-2.9: NODE_ARGS)
#    $3 = nterm term (2.9-2.9: )
# lex_state: BEG|LABEL -> BEG at line 5501
# -> $$ = nterm f_arglist (2.9-2.9: NODE_ARGS)
#
# Entering state 324
# Stack now 0 2 99 403 646 821 265 481 76 324
# Reducing stack by rule 360 (line 3556):
# -> $$ = nterm $@24 (2.9-2.9: )
#
# Entering state 565
# Stack now 0 2 99 403 646 821 265 481 76 324 565
# Reading a token
# add_delayed_token:7062 (5: 8|0|0)
# parser_dispatch_scan_event:9833 (6: 0|4|4)
# lex_state: BEG -> CMDARG at line 9733
# parser_dispatch_scan_event:10499 (6: 4|3|1)
# Next token is token "local variable or method" (6.4-6.7: bar) <------ barの呼び出し
# Shifting token "local variable or method" (6.4-6.7: bar)
#
# Entering state 35
# Stack now 0 2 99 403 646 821 265 481 76 324 565 35
# Reading a token
# add_delayed_token:7062 (6: 7|1|0)
# lex_state: CMDARG -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (6: 6|0|0)
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 652 (line 5394):
#    $1 = token "local variable or method" (6.4-6.7: bar)
# -> $$ = nterm user_variable (6.4-6.7: )
#
# Entering state 122
# Stack now 0 2 99 403 646 821 265 481 76 324 565 122
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 662 (line 5408):
#    $1 = nterm user_variable (6.4-6.7: )
# -> $$ = nterm var_ref (6.4-6.7: NODE_VCALL)
#
# Entering state 124
# Stack now 0 2 99 403 646 821 265 481 76 324 565 124
# Reducing stack by rule 318 (line 3228):
#    $1 = nterm var_ref (6.4-6.7: NODE_VCALL)
# -> $$ = nterm primary (6.4-6.7: NODE_VCALL)
#
# Entering state 90
# Stack now 0 2 99 403 646 821 265 481 76 324 565 90
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (6.4-6.7: NODE_VCALL)
# -> $$ = nterm arg (6.4-6.7: NODE_VCALL)
#
# Entering state 88
# Stack now 0 2 99 403 646 821 265 481 76 324 565 88
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (6.4-6.7: NODE_VCALL)
# -> $$ = nterm expr (6.4-6.7: NODE_VCALL)
#
# Entering state 75
# Stack now 0 2 99 403 646 821 265 481 76 324 565 75
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (6.4-6.7: NODE_VCALL)
# -> $$ = nterm stmt (6.4-6.7: NODE_VCALL)
#
# Entering state 267
# Stack now 0 2 99 403 646 821 265 481 76 324 565 267
# Next token is token '\n' (6.7-6.8: )
# Reducing stack by rule 17 (line 1704):
#    $1 = nterm stmt (6.4-6.7: NODE_VCALL)
# -> $$ = nterm stmt_or_begin (6.4-6.7: NODE_VCALL)
#
# Entering state 266
# Stack now 0 2 99 403 646 821 265 481 76 324 565 266
# Reducing stack by rule 15 (line 1688):
#    $1 = nterm stmt_or_begin (6.4-6.7: NODE_VCALL)
# -> $$ = nterm stmts (6.4-6.7: NODE_VCALL)
#
# Entering state 265
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265
# Next token is token '\n' (6.7-6.8: )
# Shifting token '\n' (6.7-6.8: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (6.7-6.8: )
# -> $$ = nterm term (6.7-6.7: )
#
# Entering state 312
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (6.7-6.7: )
# -> $$ = nterm terms (6.7-6.7: )
#
# Entering state 481
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265 481
# Reading a token
# add_delayed_token:7062 (6: 6|0|0)
# parser_dispatch_scan_event:9833 (7: 0|2|4)
# lex_state: BEG -> END at line 9707
# parser_dispatch_scan_event:10499 (7: 2|3|1)
# Next token is token "`end'" (7.2-7.5: )
# Reducing stack by rule 769 (line 6094):
#    $1 = nterm terms (6.7-6.7: )
# -> $$ = nterm opt_terms (6.7-6.7: )
#
# Entering state 480
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265 480
# Reducing stack by rule 13 (line 1675):
#    $1 = nterm stmts (6.4-6.7: NODE_VCALL)
#    $2 = nterm opt_terms (6.7-6.7: )
# -> $$ = nterm compstmt (6.4-6.7: NODE_VCALL)
#
# Entering state 626
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626
# Next token is token "`end'" (7.2-7.5: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (6.7-6.7: )
#
# Entering state 798
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 798
# Reducing stack by rule 587 (line 4961):
#    $1 = nterm none (6.7-6.7: )
# -> $$ = nterm opt_rescue (6.7-6.7: )
#
# Entering state 797
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797
# Next token is token "`end'" (7.2-7.5: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (6.7-6.7: )
#
# Entering state 968
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797 968
# Reducing stack by rule 594 (line 4995):
#    $1 = nterm none (6.7-6.7: )
# -> $$ = nterm opt_ensure (6.7-6.7: )
#
# Entering state 967
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797 967
# Reducing stack by rule 12 (line 1664):
#    $1 = nterm compstmt (6.4-6.7: NODE_VCALL)
#    $2 = nterm opt_rescue (6.7-6.7: )
#    $3 = nterm opt_ensure (6.7-6.7: )
# -> $$ = nterm bodystmt (6.4-6.7: NODE_VCALL)
#
# Entering state 746
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746
# Next token is token "`end'" (7.2-7.5: )
# Shifting token "`end'" (7.2-7.5: )
#
# Entering state 754
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746 754
# Reducing stack by rule 386 (line 3787):
#    $1 = token "`end'" (7.2-7.5: )
# -> $$ = nterm k_end (7.2-7.5: )
#
# Entering state 888
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746 888
# Reducing stack by rule 361 (line 3554):
#    $1 = nterm defn_head (2.2-2.9: NODE_DEFN)
#    $2 = nterm f_arglist (2.9-2.9: NODE_ARGS)
#    $3 = nterm $@24 (2.9-2.9: )
#    $4 = nterm bodystmt (6.4-6.7: NODE_VCALL) <-------------- メソッドの中身はbodystmtに縮退する
#    $5 = nterm k_end (7.2-7.5: )
# vtable_free:13164: p->lvtbl->args(0x000060000215f1c0)
# vtable_free:13165: p->lvtbl->vars(0x000060000215f1e0)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm primary (2.2-7.5: NODE_DEFN)
#
# Entering state 90
# Stack now 0 2 99 403 646 821 265 481 90
# Reading a token
# add_delayed_token:7062 (7: 5|1|0)
# lex_state: END -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (7: 1|0|0)
# Next token is token '\n' (7.5-7.6: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (2.2-7.5: NODE_DEFN)
# -> $$ = nterm arg (2.2-7.5: NODE_DEFN)
#
# Entering state 88
# Stack now 0 2 99 403 646 821 265 481 88
# Next token is token '\n' (7.5-7.6: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (2.2-7.5: NODE_DEFN)
# -> $$ = nterm expr (2.2-7.5: NODE_DEFN)
#
# Entering state 75
# Stack now 0 2 99 403 646 821 265 481 75
# Next token is token '\n' (7.5-7.6: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (2.2-7.5: NODE_DEFN)
# -> $$ = nterm stmt (2.2-7.5: NODE_DEFN)
#
# Entering state 267
# Stack now 0 2 99 403 646 821 265 481 267
# Next token is token '\n' (7.5-7.6: )
# Reducing stack by rule 17 (line 1704):
#    $1 = nterm stmt (2.2-7.5: NODE_DEFN)
# -> $$ = nterm stmt_or_begin (2.2-7.5: NODE_DEFN)
#
# Entering state 695
# Stack now 0 2 99 403 646 821 265 481 695
# Reducing stack by rule 16 (line 1695):
#    $1 = nterm stmts (1.9-1.9: NODE_BEGIN)
#    $2 = nterm terms (1.9-1.9: )
#    $3 = nterm stmt_or_begin (2.2-7.5: NODE_DEFN)
# -> $$ = nterm stmts (1.9-7.5: NODE_BLOCK)
#
# Entering state 265
# Stack now 0 2 99 403 646 821 265
# Next token is token '\n' (7.5-7.6: )
# Shifting token '\n' (7.5-7.6: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (7.5-7.6: )
# -> $$ = nterm term (7.5-7.5: )
#
# Entering state 312
# Stack now 0 2 99 403 646 821 265 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (7.5-7.5: )
# -> $$ = nterm terms (7.5-7.5: )
#
# Entering state 481
# Stack now 0 2 99 403 646 821 265 481
# Reading a token
# add_delayed_token:7062 (7: 1|0|0)
# parser_dispatch_scan_event:9857 (8: 0|1|0)
# add_delayed_token:7062 (8: 1|0|0)
# parser_dispatch_scan_event:9833 (9: 0|2|8)
# lex_state: BEG -> FNAME at line 9707
# parser_dispatch_scan_event:10499 (9: 2|3|5)
# Next token is token "`def'" (9.2-9.5: )
# Shifting token "`def'" (9.2-9.5: )
#
# Entering state 7
# Stack now 0 2 99 403 646 821 265 481 7
# Reducing stack by rule 378 (line 3721):
#    $1 = token "`def'" (9.2-9.5: )
# -> $$ = nterm k_def (9.2-9.5: )
#
# Entering state 101
# Stack now 0 2 99 403 646 821 265 481 101
# Reading a token
# parser_dispatch_scan_event:9833 (9: 5|1|4)
# lex_state: FNAME -> ENDFN at line 9740
# parser_dispatch_scan_event:10499 (9: 6|3|1)
# Next token is token "local variable or method" (9.6-9.9: bar)
# Shifting token "local variable or method" (9.6-9.9: bar)
#
# Entering state 416
# Stack now 0 2 99 403 646 821 265 481 101 416
# Reading a token
# add_delayed_token:7062 (9: 9|1|0)
# lex_state: ENDFN -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (9: 6|0|0)
# Next token is token '\n' (9.9-9.10: )
# Reducing stack by rule 135 (line 2545):
#    $1 = token "local variable or method" (9.6-9.9: bar)
# -> $$ = nterm fname (9.6-9.9: )
#
# Entering state 420
# Stack now 0 2 99 403 646 821 265 481 101 420
# Reducing stack by rule 66 (line 2054):
#    $1 = nterm fname (9.6-9.9: )
# vtable_alloc:13130: 0x000060000215f7e0
# vtable_alloc:13131: 0x000060000215f800
# cmdarg_stack(push): 0 at line 13144
# cond_stack(push): 0 at line 13145
# -> $$ = nterm def_name (9.6-9.9: NODE_SELF)
#
# Entering state 419
# Stack now 0 2 99 403 646 821 265 481 101 419
# Reducing stack by rule 67 (line 2071):
#    $1 = nterm k_def (9.2-9.5: )
#    $2 = nterm def_name (9.6-9.9: NODE_SELF)
# -> $$ = nterm defn_head (9.2-9.9: NODE_DEFN)
#
# Entering state 76
# Stack now 0 2 99 403 646 821 265 481 76
# Next token is token '\n' (9.9-9.10: )
# Reducing stack by rule 675 (line 5490):
# lex_state: BEG -> BEG|LABEL at line 5494
# -> $$ = nterm @50 (9.9-9.9: )
#
# Entering state 325
# Stack now 0 2 99 403 646 821 265 481 76 325
# Next token is token '\n' (9.9-9.10: )
# Reducing stack by rule 698 (line 5599):
# -> $$ = nterm f_args (9.9-9.9: NODE_ARGS)
#
# Entering state 566
# Stack now 0 2 99 403 646 821 265 481 76 325 566
# Next token is token '\n' (9.9-9.10: )
# Shifting token '\n' (9.9-9.10: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 481 76 325 566 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (9.9-9.10: )
# -> $$ = nterm term (9.9-9.9: )
#
# Entering state 747
# Stack now 0 2 99 403 646 821 265 481 76 325 566 747
# Reducing stack by rule 676 (line 5490):
#    $1 = nterm @50 (9.9-9.9: )
#    $2 = nterm f_args (9.9-9.9: NODE_ARGS)
#    $3 = nterm term (9.9-9.9: )
# lex_state: BEG|LABEL -> BEG at line 5501
# -> $$ = nterm f_arglist (9.9-9.9: NODE_ARGS)
#
# Entering state 324
# Stack now 0 2 99 403 646 821 265 481 76 324
# Reducing stack by rule 360 (line 3556):
# -> $$ = nterm $@24 (9.9-9.9: )
#
# Entering state 565
# Stack now 0 2 99 403 646 821 265 481 76 324 565
# Reading a token
# add_delayed_token:7062 (9: 6|0|0)
# parser_dispatch_scan_event:9833 (10: 0|2|4)
# lex_state: BEG -> END at line 9707
# parser_dispatch_scan_event:10499 (10: 2|3|1)
# Next token is token "`end'" (10.2-10.5: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (9.9-9.9: )
#
# Entering state 270
# Stack now 0 2 99 403 646 821 265 481 76 324 565 270
# Reducing stack by rule 14 (line 1681):
#    $1 = nterm none (9.9-9.9: )
# -> $$ = nterm stmts (9.9-9.9: NODE_BEGIN)
#
# Entering state 265
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265
# Next token is token "`end'" (10.2-10.5: )
# Reducing stack by rule 768 (line 6093):
# -> $$ = nterm opt_terms (9.9-9.9: )
#
# Entering state 480
# Stack now 0 2 99 403 646 821 265 481 76 324 565 265 480
# Reducing stack by rule 13 (line 1675):
#    $1 = nterm stmts (9.9-9.9: NODE_BEGIN)
#    $2 = nterm opt_terms (9.9-9.9: )
# -> $$ = nterm compstmt (9.9-9.9: NODE_BEGIN)
#
# Entering state 626
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626
# Next token is token "`end'" (10.2-10.5: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (9.9-9.9: )
#
# Entering state 798
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 798
# Reducing stack by rule 587 (line 4961):
#    $1 = nterm none (9.9-9.9: )
# -> $$ = nterm opt_rescue (9.9-9.9: )
#
# Entering state 797
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797
# Next token is token "`end'" (10.2-10.5: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (9.9-9.9: )
#
# Entering state 968
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797 968
# Reducing stack by rule 594 (line 4995):
#    $1 = nterm none (9.9-9.9: )
# -> $$ = nterm opt_ensure (9.9-9.9: )
#
# Entering state 967
# Stack now 0 2 99 403 646 821 265 481 76 324 565 626 797 967
# Reducing stack by rule 12 (line 1664):
#    $1 = nterm compstmt (9.9-9.9: NODE_BEGIN)
#    $2 = nterm opt_rescue (9.9-9.9: )
#    $3 = nterm opt_ensure (9.9-9.9: )
# -> $$ = nterm bodystmt (9.9-9.9: NODE_BEGIN)
#
# Entering state 746
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746
# Next token is token "`end'" (10.2-10.5: )
# Shifting token "`end'" (10.2-10.5: )
#
# Entering state 754
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746 754
# Reducing stack by rule 386 (line 3787):
#    $1 = token "`end'" (10.2-10.5: )
# -> $$ = nterm k_end (10.2-10.5: )
#
# Entering state 888
# Stack now 0 2 99 403 646 821 265 481 76 324 565 746 888
# Reducing stack by rule 361 (line 3554):
#    $1 = nterm defn_head (9.2-9.9: NODE_DEFN)
#    $2 = nterm f_arglist (9.9-9.9: NODE_ARGS)
#    $3 = nterm $@24 (9.9-9.9: )
#    $4 = nterm bodystmt (9.9-9.9: NODE_BEGIN)
#    $5 = nterm k_end (10.2-10.5: )
# vtable_free:13164: p->lvtbl->args(0x000060000215f7e0)
# vtable_free:13165: p->lvtbl->vars(0x000060000215f800)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm primary (9.2-10.5: NODE_DEFN)
#
# Entering state 90
# Stack now 0 2 99 403 646 821 265 481 90
# Reading a token
# add_delayed_token:7062 (10: 5|1|0)
# lex_state: END -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (10: 4|0|0)
# Next token is token '\n' (10.5-10.6: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (9.2-10.5: NODE_DEFN)
# -> $$ = nterm arg (9.2-10.5: NODE_DEFN)
#
# Entering state 88
# Stack now 0 2 99 403 646 821 265 481 88
# Next token is token '\n' (10.5-10.6: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (9.2-10.5: NODE_DEFN)
# -> $$ = nterm expr (9.2-10.5: NODE_DEFN)
#
# Entering state 75
# Stack now 0 2 99 403 646 821 265 481 75
# Next token is token '\n' (10.5-10.6: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (9.2-10.5: NODE_DEFN)
# -> $$ = nterm stmt (9.2-10.5: NODE_DEFN)
#
# Entering state 267
# Stack now 0 2 99 403 646 821 265 481 267
# Next token is token '\n' (10.5-10.6: )
# Reducing stack by rule 17 (line 1704):
#    $1 = nterm stmt (9.2-10.5: NODE_DEFN)
# -> $$ = nterm stmt_or_begin (9.2-10.5: NODE_DEFN)
#
# Entering state 695
# Stack now 0 2 99 403 646 821 265 481 695
# Reducing stack by rule 16 (line 1695):
#    $1 = nterm stmts (1.9-7.5: NODE_BLOCK)
#    $2 = nterm terms (7.5-7.5: )
#    $3 = nterm stmt_or_begin (9.2-10.5: NODE_DEFN)
# -> $$ = nterm stmts (1.9-10.5: NODE_BLOCK)
#
# Entering state 265
# Stack now 0 2 99 403 646 821 265
# Next token is token '\n' (10.5-10.6: )
# Shifting token '\n' (10.5-10.6: )
#
# Entering state 310
# Stack now 0 2 99 403 646 821 265 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (10.5-10.6: )
# -> $$ = nterm term (10.5-10.5: )
#
# Entering state 312
# Stack now 0 2 99 403 646 821 265 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (10.5-10.5: )
# -> $$ = nterm terms (10.5-10.5: )
#
# Entering state 481
# Stack now 0 2 99 403 646 821 265 481
# Reading a token
# add_delayed_token:7062 (10: 4|0|0)
# lex_state: BEG -> END at line 9707
# parser_dispatch_scan_event:10499 (11: 0|3|1)
# Next token is token "`end'" (11.0-11.3: )
# Reducing stack by rule 769 (line 6094):
#    $1 = nterm terms (10.5-10.5: )
# -> $$ = nterm opt_terms (10.5-10.5: )
#
# Entering state 480
# Stack now 0 2 99 403 646 821 265 480
# Reducing stack by rule 13 (line 1675):
#    $1 = nterm stmts (1.9-10.5: NODE_BLOCK)
#    $2 = nterm opt_terms (10.5-10.5: )
# -> $$ = nterm compstmt (1.9-10.5: NODE_BLOCK)
#
# Entering state 626
# Stack now 0 2 99 403 646 821 626
# Next token is token "`end'" (11.0-11.3: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (10.5-10.5: )
#
# Entering state 798
# Stack now 0 2 99 403 646 821 626 798
# Reducing stack by rule 587 (line 4961):
#    $1 = nterm none (10.5-10.5: )
# -> $$ = nterm opt_rescue (10.5-10.5: )
#
# Entering state 797
# Stack now 0 2 99 403 646 821 626 797
# Next token is token "`end'" (11.0-11.3: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (10.5-10.5: )
#
# Entering state 968
# Stack now 0 2 99 403 646 821 626 797 968
# Reducing stack by rule 594 (line 4995):
#    $1 = nterm none (10.5-10.5: )
# -> $$ = nterm opt_ensure (10.5-10.5: )
#
# Entering state 967
# Stack now 0 2 99 403 646 821 626 797 967
# Reducing stack by rule 12 (line 1664):
#    $1 = nterm compstmt (1.9-10.5: NODE_BLOCK)
#    $2 = nterm opt_rescue (10.5-10.5: )
#    $3 = nterm opt_ensure (10.5-10.5: )
# -> $$ = nterm bodystmt (1.9-10.5: NODE_BLOCK)
#
# Entering state 988
# Stack now 0 2 99 403 646 821 988
# Next token is token "`end'" (11.0-11.3: )
# Shifting token "`end'" (11.0-11.3: )
#
# Entering state 754
# Stack now 0 2 99 403 646 821 988 754
# Reducing stack by rule 386 (line 3787):
#    $1 = token "`end'" (11.0-11.3: )
# -> $$ = nterm k_end (11.0-11.3: )
#
# Entering state 1101
# Stack now 0 2 99 403 646 821 988 1101
# Reducing stack by rule 355 (line 3486):
#    $1 = nterm k_class (1.0-1.5: )
#    $2 = nterm cpath (1.6-1.9: NODE_COLON2)
#    $3 = nterm superclass (1.9-1.9: )
#    $4 = nterm $@21 (1.9-1.9: )
#    $5 = nterm bodystmt (1.9-10.5: NODE_BLOCK)
#    $6 = nterm k_end (11.0-11.3: )
# vtable_free:13164: p->lvtbl->args(0x000060000215efc0)
# vtable_free:13165: p->lvtbl->vars(0x000060000215efe0)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm primary (1.0-11.3: NODE_CLASS)
#
# Entering state 90
# Stack now 0 2 90
# Reading a token
# add_delayed_token:7062 (11: 3|1|0)
# lex_state: END -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (11: 1|0|0)
# Next token is token '\n' (11.3-11.4: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (1.0-11.3: NODE_CLASS)
# -> $$ = nterm arg (1.0-11.3: NODE_CLASS)
#
# Entering state 88
# Stack now 0 2 88
# Next token is token '\n' (11.3-11.4: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (1.0-11.3: NODE_CLASS)
# -> $$ = nterm expr (1.0-11.3: NODE_CLASS)
#
# Entering state 75
# Stack now 0 2 75
# Next token is token '\n' (11.3-11.4: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (1.0-11.3: NODE_CLASS)
# -> $$ = nterm stmt (1.0-11.3: NODE_CLASS)
#
# Entering state 73
# Stack now 0 2 73
# Next token is token '\n' (11.3-11.4: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (1.0-11.3: NODE_CLASS)
# -> $$ = nterm top_stmt (1.0-11.3: NODE_CLASS)
#
# Entering state 72
# Stack now 0 2 72
# Reducing stack by rule 5 (line 1619):
#    $1 = nterm top_stmt (1.0-11.3: NODE_CLASS)
# -> $$ = nterm top_stmts (1.0-11.3: NODE_CLASS)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (11.3-11.4: )
# Shifting token '\n' (11.3-11.4: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (11.3-11.4: )
# -> $$ = nterm term (11.3-11.3: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (11.3-11.3: )
# -> $$ = nterm terms (11.3-11.3: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# add_delayed_token:7062 (11: 1|0|0)
# parser_dispatch_scan_event:9857 (12: 0|1|0)
# add_delayed_token:7062 (12: 1|0|0)
# lex_state: BEG -> CMDARG at line 9733
# parser_dispatch_scan_event:10499 (13: 0|3|9)
# Next token is token "constant" (13.0-13.3: Foo)
# Shifting token "constant" (13.0-13.3: Foo)
#
# Entering state 39
# Stack now 0 2 71 313 39
# Reading a token
# lex_state: CMDARG -> BEG at line 10218
# lex_state: BEG -> DOT at line 10252
# parser_dispatch_scan_event:10499 (13: 3|1|8)
# Next token is token '.' (13.3-13.4: )
# Reducing stack by rule 653 (line 5395):
#    $1 = token "constant" (13.0-13.3: Foo)
# -> $$ = nterm user_variable (13.0-13.3: )
#
# Entering state 122
# Stack now 0 2 71 313 122
# Next token is token '.' (13.3-13.4: )
# Reducing stack by rule 662 (line 5408):
#    $1 = nterm user_variable (13.0-13.3: )
# -> $$ = nterm var_ref (13.0-13.3: NODE_CONST)
#
# Entering state 124
# Stack now 0 2 71 313 124
# Reducing stack by rule 318 (line 3228):
#    $1 = nterm var_ref (13.0-13.3: NODE_CONST)
# -> $$ = nterm primary (13.0-13.3: NODE_CONST)
#
# Entering state 90
# Stack now 0 2 71 313 90
# Next token is token '.' (13.3-13.4: )
# Reducing stack by rule 368 (line 3620):
#    $1 = nterm primary (13.0-13.3: NODE_CONST)
# -> $$ = nterm primary_value (13.0-13.3: NODE_CONST)
#
# Entering state 91
# Stack now 0 2 71 313 91
# Next token is token '.' (13.3-13.4: )
# Shifting token '.' (13.3-13.4: )
#
# Entering state 374
# Stack now 0 2 71 313 91 374
# Reducing stack by rule 764 (line 6085):
#    $1 = token '.' (13.3-13.4: )
# -> $$ = nterm call_op (13.3-13.4: )
#
# Entering state 378
# Stack now 0 2 71 313 91 378
# Reading a token
# lex_state: DOT -> ARG at line 9736
# parser_dispatch_scan_event:10499 (13: 4|3|5)
# Next token is token "local variable or method" (13.4-13.7: new)
# Shifting token "local variable or method" (13.4-13.7: new)
#
# Entering state 619
# Stack now 0 2 71 313 91 378 619
# Reading a token
# lex_state: ARG -> BEG at line 10218
# lex_state: BEG -> DOT at line 10252
# parser_dispatch_scan_event:10499 (13: 7|1|4)
# Next token is token '.' (13.7-13.8: )
# Reducing stack by rule 754 (line 6067):
#    $1 = token "local variable or method" (13.4-13.7: new)
# -> $$ = nterm operation (13.4-13.7: )
#
# Entering state 614
# Stack now 0 2 71 313 91 378 614
# Reducing stack by rule 757 (line 6072):
#    $1 = nterm operation (13.4-13.7: )
# -> $$ = nterm operation2 (13.4-13.7: )
#
# Entering state 624
# Stack now 0 2 71 313 91 378 624
# Next token is token '.' (13.7-13.8: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (13.7-13.7: )
#
# Entering state 793
# Stack now 0 2 71 313 91 378 624 793
# Reducing stack by rule 281 (line 3011):
#    $1 = nterm none (13.7-13.7: )
# -> $$ = nterm opt_paren_args (13.7-13.7: )
#
# Entering state 791
# Stack now 0 2 71 313 91 378 624 791
# Reducing stack by rule 463 (line 4230):
#    $1 = nterm primary_value (13.0-13.3: NODE_CONST)
#    $2 = nterm call_op (13.3-13.4: )
#    $3 = nterm operation2 (13.4-13.7: )
#    $4 = nterm opt_paren_args (13.7-13.7: )
# -> $$ = nterm method_call (13.0-13.7: NODE_CALL)
#
# Entering state 105
# Stack now 0 2 71 313 105
# Next token is token '.' (13.7-13.8: )
# Reducing stack by rule 341 (line 3352):
#    $1 = nterm method_call (13.0-13.7: NODE_CALL)
# -> $$ = nterm primary (13.0-13.7: NODE_CALL)
#
# Entering state 90
# Stack now 0 2 71 313 90
# Next token is token '.' (13.7-13.8: )
# Reducing stack by rule 368 (line 3620):
#    $1 = nterm primary (13.0-13.7: NODE_CALL)
# -> $$ = nterm primary_value (13.0-13.7: NODE_CALL)
#
# Entering state 91
# Stack now 0 2 71 313 91
# Next token is token '.' (13.7-13.8: )
# Shifting token '.' (13.7-13.8: )
#
# Entering state 374
# Stack now 0 2 71 313 91 374
# Reducing stack by rule 764 (line 6085):
#    $1 = token '.' (13.7-13.8: )
# -> $$ = nterm call_op (13.7-13.8: )
#
# Entering state 378
# Stack now 0 2 71 313 91 378
# Reading a token
# lex_state: DOT -> ARG at line 9736
# parser_dispatch_scan_event:10499 (13: 8|3|1)
# Next token is token "local variable or method" (13.8-13.11: foo)
# Shifting token "local variable or method" (13.8-13.11: foo)
#
# Entering state 619
# Stack now 0 2 71 313 91 378 619
# Reading a token
# add_delayed_token:7062 (13: 11|1|0)
# lex_state: ARG -> BEG at line 9900
# parser_dispatch_delayed_token:10497 (13: 1|0|0)
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 754 (line 6067):
#    $1 = token "local variable or method" (13.8-13.11: foo)
# -> $$ = nterm operation (13.8-13.11: )
#
# Entering state 614
# Stack now 0 2 71 313 91 378 614
# Reducing stack by rule 757 (line 6072):
#    $1 = nterm operation (13.8-13.11: )
# -> $$ = nterm operation2 (13.8-13.11: )
#
# Entering state 624
# Stack now 0 2 71 313 91 378 624
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 781 (line 6127):
# -> $$ = nterm none (13.11-13.11: )
#
# Entering state 793
# Stack now 0 2 71 313 91 378 624 793
# Reducing stack by rule 281 (line 3011):
#    $1 = nterm none (13.11-13.11: )
# -> $$ = nterm opt_paren_args (13.11-13.11: )
#
# Entering state 791
# Stack now 0 2 71 313 91 378 624 791
# Reducing stack by rule 463 (line 4230):
#    $1 = nterm primary_value (13.0-13.7: NODE_CALL)
#    $2 = nterm call_op (13.7-13.8: )
#    $3 = nterm operation2 (13.8-13.11: )
#    $4 = nterm opt_paren_args (13.11-13.11: )
# -> $$ = nterm method_call (13.0-13.11: NODE_CALL)
#
# Entering state 105
# Stack now 0 2 71 313 105
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 341 (line 3352):
#    $1 = nterm method_call (13.0-13.11: NODE_CALL)
# -> $$ = nterm primary (13.0-13.11: NODE_CALL)
#
# Entering state 90
# Stack now 0 2 71 313 90
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 263 (line 2906):
#    $1 = nterm primary (13.0-13.11: NODE_CALL)
# -> $$ = nterm arg (13.0-13.11: NODE_CALL)
#
# Entering state 88
# Stack now 0 2 71 313 88
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 65 (line 2051):
#    $1 = nterm arg (13.0-13.11: NODE_CALL)
# -> $$ = nterm expr (13.0-13.11: NODE_CALL)
#
# Entering state 75
# Stack now 0 2 71 313 75
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 37 (line 1853):
#    $1 = nterm expr (13.0-13.11: NODE_CALL)
# -> $$ = nterm stmt (13.0-13.11: NODE_CALL)
#
# Entering state 73
# Stack now 0 2 71 313 73
# Next token is token '\n' (13.11-13.12: )
# Reducing stack by rule 7 (line 1635):
#    $1 = nterm stmt (13.0-13.11: NODE_CALL)
# -> $$ = nterm top_stmt (13.0-13.11: NODE_CALL)
#
# Entering state 520
# Stack now 0 2 71 313 520
# Reducing stack by rule 6 (line 1626):
#    $1 = nterm top_stmts (1.0-11.3: NODE_CLASS)
#    $2 = nterm terms (11.3-11.3: )
#    $3 = nterm top_stmt (13.0-13.11: NODE_CALL)
# -> $$ = nterm top_stmts (1.0-13.11: NODE_BLOCK)
#
# Entering state 71
# Stack now 0 2 71
# Next token is token '\n' (13.11-13.12: )
# Shifting token '\n' (13.11-13.12: )
#
# Entering state 310
# Stack now 0 2 71 310
# Reducing stack by rule 778 (line 6115):
#    $1 = token '\n' (13.11-13.12: )
# -> $$ = nterm term (13.11-13.11: )
#
# Entering state 312
# Stack now 0 2 71 312
# Reducing stack by rule 779 (line 6122):
#    $1 = nterm term (13.11-13.11: )
# -> $$ = nterm terms (13.11-13.11: )
#
# Entering state 313
# Stack now 0 2 71 313
# Reading a token
# add_delayed_token:7062 (13: 1|0|0)
# parser_dispatch_scan_event:9857 (14: 0|1|0)
# add_delayed_token:7062 (14: 1|0|0)
# parser_dispatch_scan_event:10499 (15: 0|1|7)
# Now at end of input.
# Reducing stack by rule 769 (line 6094):
#    $1 = nterm terms (13.11-13.11: )
# -> $$ = nterm opt_terms (13.11-13.11: )
#
# Entering state 311
# Stack now 0 2 71 311
# Reducing stack by rule 3 (line 1606):
#    $1 = nterm top_stmts (1.0-13.11: NODE_BLOCK)
#    $2 = nterm opt_terms (13.11-13.11: )
# -> $$ = nterm top_compstmt (1.0-13.11: NODE_BLOCK)
#
# Entering state 70
# Stack now 0 2 70
# Reducing stack by rule 2 (line 1580):
#    $1 = nterm $@1 (1.0-1.0: )
#    $2 = nterm top_compstmt (1.0-13.11: NODE_BLOCK)
# vtable_free:13164: p->lvtbl->args(0x000060000215ed80)
# vtable_free:13165: p->lvtbl->vars(0x000060000215eda0)
# cmdarg_stack(pop): 0 at line 13166
# cond_stack(pop): 0 at line 13167
# -> $$ = nterm program (1.0-13.11: )
#
# Entering state 1
# Stack now 0 1
# Now at end of input.
# Shifting token "end-of-input" (15.0-15.1: )
#
# Entering state 3
# Stack now 0 1 3
# Stack now 0 1 3
# Cleanup: popping token "end-of-input" (15.0-15.1: )
# Cleanup: popping nterm program (1.0-13.11: )
# Syntax OK
