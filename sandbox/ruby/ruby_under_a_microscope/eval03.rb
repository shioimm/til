def get_binding
  x = 'in get_binding'
  binding
end

x = 'out of get_binding'
eval("puts x", get_binding)

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(7,27)> (catch: FALSE)
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] x@0
# 0000 definemethod                           :get_binding, get_binding (   1)[Li]
# 0003 putstring                              "out of get_binding"      (   6)[Li]
# 0005 setlocal_WC_0                          x@0
# 0007 putself                                                          (   7)[Li]
# 0008 putstring                              "puts x"
# 0010 putself
# 0011 opt_send_without_block                 <calldata!mid:get_binding, argc:0, FCALL|VCALL|ARGS_SIMPLE>
# 0013 opt_send_without_block                 <calldata!mid:eval, argc:2, FCALL|ARGS_SIMPLE>
# 0015 leave
#
# == disasm: #<ISeq:get_binding@<compiled>:1 (1,0)-(4,3)> (catch: FALSE)
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] x@0
# 0000 putstring                              "in get_binding"          (   2)[LiCa]
# 0002 setlocal_WC_0                          x@0
# 0004 putself                                                          (   3)[Li]
# 0005 opt_send_without_block                 <calldata!mid:binding, argc:0, FCALL|VCALL|ARGS_SIMPLE>
# 0007 leave
