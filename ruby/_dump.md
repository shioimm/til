# `$ ruby --dump`
#### `insns` / `insns_without_opt` (YARV命令列)

```
$ ruby --dump=insns -e '1 + 2'
== disasm: #<ISeq:<main>@-e:1 (1,0)-(1,5)> (catch: false)
0000 putobject_INT2FIX_1_                                             (   1)[Li]
0001 putobject                              2
0003 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
0005 leave
```

#### `yydebug(+error-tolerant)`

```
$ ruby --dump=yydebug
... # $ ruby -y オプションと同じ
```

#### `parsetree(+error-tolerant)` / `parsetree_with_comment(+error-tolerant)` (AST)

```
$ ruby --dump=parsetree -e '1 + 2'
###########################################################
## Do NOT use this node dump for any purpose other than  ##
## debug and research.  Compatibility is not guaranteed. ##
###########################################################

# @ NODE_SCOPE (id: 4, line: 1, location: (1,0)-(1,5))
# +- nd_tbl: (empty)
# +- nd_args:
# |   (null node)
# +- nd_body:
#     @ NODE_OPCALL (id: 3, line: 1, location: (1,0)-(1,5))*
#     +- nd_mid: :+
#     +- nd_recv:
#     |   @ NODE_LIT (id: 0, line: 1, location: (1,0)-(1,1))
#     |   +- nd_lit: 1
#     +- nd_args:
#         @ NODE_LIST (id: 2, line: 1, location: (1,4)-(1,5))
#         +- nd_alen: 1
#         +- nd_head:
#         |   @ NODE_LIT (id: 1, line: 1, location: (1,4)-(1,5))
#         |   +- nd_lit: 2
#         +- nd_next:
#             (null node)
```
