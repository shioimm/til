3.times(&proc { p :ok })

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,24)> (catch: FALSE)
# 0000 putobject                              3                         (   1)[Li]
# 0002 putself
# 0003 send                                   <calldata!mid:proc, argc:0, FCALL>, block in <compiled>
# 0006 send                                   <calldata!mid:times, argc:0, ARGS_BLOCKARG>, nil
# 0009 leave
#
# == disasm: #<ISeq:block in <compiled>@<compiled>:1 (1,14)-(1,23)> (catch: FALSE)
# 0000 putself                                                          (   1)[LiBc]
# 0001 putobject                              :ok
# 0003 opt_send_without_block                 <calldata!mid:p, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
