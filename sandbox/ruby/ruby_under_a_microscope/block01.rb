3.times { p :ok }

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,17)> (catch: FALSE)
# 0000 putobject                              3                         (   1)[Li]
# 0002 send                                   <calldata!mid:times, argc:0>, block in <compiled>
# 0005 leave
#
# == disasm: #<ISeq:block in <compiled>@<compiled>:1 (1,8)-(1,17)> (catch: FALSE)
# 0000 putself                                                          (   1)[LiBc]
# 0001 putobject                              :ok
# 0003 opt_send_without_block                 <calldata!mid:p, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
