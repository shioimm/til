C = 1

module Outer
  C
  class Inner
    C
  end
end

C

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(10,1)> (catch: FALSE)
# 0000 putobject_INT2FIX_1_                                             (   1)[Li]
# 0001 putspecialobject                       3
# 0003 setconstant                            :C
# 0005 putspecialobject                       3                         (   3)[Li]
# 0007 putnil
# 0008 defineclass                            :Outer, <module:Outer>, 2
# 0012 pop
# 0013 opt_getinlinecache                     22, <is:0>                (  10)[Li]
# 0016 putobject                              true
# 0018 getconstant                            :C
# 0020 opt_setinlinecache                     <is:0>
# 0022 leave
#
# == disasm: #<ISeq:<module:Outer>@<compiled>:3 (3,0)-(8,3)> (catch: FALSE)
# 0000 opt_getinlinecache                     9, <is:0>                 (   4)[LiCl]
# 0003 putobject                              true
# 0005 getconstant                            :C
# 0007 opt_setinlinecache                     <is:0>
# 0009 pop
# 0010 putspecialobject                       3                         (   5)[Li]
# 0012 putnil
# 0013 defineclass                            :Inner, <class:Inner>, 0
# 0017 leave                                                            (   8)[En]
#
# == disasm: #<ISeq:<class:Inner>@<compiled>:5 (5,2)-(7,5)> (catch: FALSE)
# 0000 opt_getinlinecache                     9, <is:0>                 (   6)[LiCl]
# 0003 putobject                              true
# 0005 getconstant                            :C
# 0007 opt_setinlinecache                     <is:0>
# 0009 leave
