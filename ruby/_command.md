# `ruby`コマンド
#### `--dump parsetree`
- 構文解析後のAST構造体の状態を出力

```
$ ruby --dump parsetree -e '2 + 1'

# @ NODE_SCOPE (id: 4, line: 1, location: (1,0)-(1,5))
# +- nd_tbl: (empty)
# +- nd_args:
# |   (null node)
# +- nd_body:
#     @ NODE_OPCALL (id: 3, line: 1, location: (1,0)-(1,5))*
#     +- nd_mid: :+
#     +- nd_recv:
#     |   @ NODE_LIT (id: 0, line: 1, location: (1,0)-(1,1))
#     |   +- nd_lit: 2
#     +- nd_args:
#         @ NODE_LIST (id: 2, line: 1, location: (1,4)-(1,5))
#         +- nd_alen: 1
#         +- nd_head:
#         |   @ NODE_LIT (id: 1, line: 1, location: (1,4)-(1,5))
#         |   +- nd_lit: 1
#         +- nd_next:
#             (null node)

# Ripper.sexpとの比較
# require 'ripper'; pp Ripper.sexp('2 + 1')
# [
#   :program,
#   [
#     [
#       :binary,
#       [:@int, "2", [1, 0]],
#       :+,
#       [:@int, "1", [1, 4]]
#     ]
#   ]
# ]
```
