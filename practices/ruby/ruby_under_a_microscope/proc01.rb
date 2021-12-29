source =<<SRC
pr = Proc.new { puts 'Proc is called' }
pr.call
SRC
puts RubyVM::InstructionSequence.compile(source).disasm

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(2,6)> (catch: FALSE)
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] p@0
# 0000 opt_getinlinecache                     9, <is:0>                 (   1)[Li]
# 0003 putobject                              true
# 0005 getconstant                            :Proc
# 0007 opt_setinlinecache                     <is:0>
# 0009 send                                   <calldata!mid:new, argc:0>, block in <compiled>
# 0012 setlocal_WC_0                          p@0
# 0014 getlocal_WC_0                          p@0                       (   2)[Li]
# 0016 opt_send_without_block                 <calldata!mid:call, argc:0, ARGS_SIMPLE>
# 0018 leave
#
# == disasm: #<ISeq:block in <compiled>@<compiled>:1 (1,13)-(1,38)> (catch: FALSE)
# 0000 putself                                                          (   1)[LiBc]
# 0001 putstring                              "Proc is called"
# 0003 opt_send_without_block                 <calldata!mid:puts, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
