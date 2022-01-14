class C
  def m = 1.times {}
end
C.new.m

# toplevel 命令列:
#   クラス C の命令列:
#     メソッド m の命令列:
#       ブロックの命令列

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(7,7)> (catch: FALSE)
# 0000 putspecialobject                       3                         (   1)[Li]
# 0002 putnil
# 0003 defineclass                            :C, <class:C>, 0
# 0007 pop
# 0008 opt_getinlinecache                     17, <is:0>                (   7)[Li]
# 0011 putobject                              true
# 0013 getconstant                            :C
# 0015 opt_setinlinecache                     <is:0>
# 0017 opt_send_without_block                 <calldata!mid:new, argc:0, ARGS_SIMPLE>
# 0019 opt_send_without_block                 <calldata!mid:m, argc:0, ARGS_SIMPLE>
# 0021 leave
#
# == disasm: #<ISeq:<class:C>@<compiled>:1 (1,0)-(6,3)> (catch: FALSE)
# 0000 definemethod                           :m, m                     (   2)[LiCl]
# 0003 putobject                              :m
# 0005 leave                                                            (   6)[En]
#
# == disasm: #<ISeq:m@<compiled>:2 (2,2)-(5,5)> (catch: FALSE)
# 0000 putobject_INT2FIX_1_                                             (   3)[LiCa]
# 0001 send                                   <calldata!mid:times, argc:0>, block in m
# 0004 leave                                                            (   5)[Re]
# 
# == disasm: #<ISeq:block in m@<compiled>:3 (3,11)-(4,5)> (catch: FALSE)
# 0000 putnil                                                           (   3)[Bc]
# 0001 leave                                                            (   4)[Br]
