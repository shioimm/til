p = Proc.new { |n| puts n }
p.call('Proc is called')

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(2,24)> (catch: FALSE)
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] p@0
# 0000 opt_getinlinecache                     9, <is:0>                 (   1)[Li]
# 0003 putobject                              true
# 0005 getconstant                            :Proc
# 0007 opt_setinlinecache                     <is:0>
# 0009 send                                   <calldata!mid:new, argc:0>, block in <compiled>
# 0012 setlocal_WC_0                          p@0
# 0014 getlocal_WC_0                          p@0                       (   2)[Li]
# 0016 putstring                              "Proc is called"
# 0018 opt_send_without_block                 <calldata!mid:call, argc:1, ARGS_SIMPLE>
# 0020 leave
#
# == disasm: #<ISeq:block in <compiled>@<compiled>:1 (1,13)-(1,27)> (catch: FALSE)
# local table (size: 1, argc: 1 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] n@0<Arg>
# 0000 putself                                                          (   1)[LiBc]
# 0001 getlocal_WC_0                          n@0
# 0003 opt_send_without_block                 <calldata!mid:puts, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
