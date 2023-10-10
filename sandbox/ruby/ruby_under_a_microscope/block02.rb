3.times { |i| p i }

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,19)> (catch: FALSE)
# 0000 putobject                              3                         (   1)[Li]
# 0002 send                                   <calldata!mid:times, argc:0>, block in <compiled>
# 0005 leave
#
# == disasm: #<ISeq:block in <compiled>@<compiled>:1 (1,8)-(1,19)> (catch: FALSE)
# local table (size: 1, argc: 1 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] i@0<Arg>
# 0000 putself                                                          (   1)[LiBc]
# 0001 getlocal_WC_0                          i@0
# 0003 opt_send_without_block                 <calldata!mid:p, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
