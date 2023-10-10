code = "p 1 + 2"
eval(code)

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(2,10)> (catch: FALSE)
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] code@0
# 0000 putstring                              "p 1 + 2"                 (   1)[Li]
# 0002 setlocal_WC_0                          code@0
# 0004 putself                                                          (   2)[Li]
# 0005 getlocal_WC_0                          code@0
# 0007 opt_send_without_block                 <calldata!mid:eval, argc:1, FCALL|ARGS_SIMPLE>
# 0009 leave
