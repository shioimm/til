a = 'hello'
b = 'eval'
str = "puts"
str += " a"
str += " +"
str += " b"
eval("puts #{a} + #{b}")

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(7,24)> (catch: FALSE)
# local table (size: 3, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 3] a@0        [ 2] b@1        [ 1] str@2
# 0000 putstring                              "hello"                   (   1)[Li]
# 0002 setlocal_WC_0                          a@0
# 0004 putstring                              "eval"                    (   2)[Li]
# 0006 setlocal_WC_0                          b@1
# 0008 putstring                              "puts"                    (   3)[Li]
# 0010 setlocal_WC_0                          str@2
# 0012 getlocal_WC_0                          str@2                     (   4)[Li]
# 0014 putstring                              " a"
# 0016 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
# 0018 setlocal_WC_0                          str@2
# 0020 getlocal_WC_0                          str@2                     (   5)[Li]
# 0022 putstring                              " +"
# 0024 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
# 0026 setlocal_WC_0                          str@2
# 0028 getlocal_WC_0                          str@2                     (   6)[Li]
# 0030 putstring                              " b"
# 0032 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
# 0034 setlocal_WC_0                          str@2
# 0036 putself                                                          (   7)[Li]
# 0037 putobject                              "puts "
# 0039 getlocal_WC_0                          a@0
# 0041 dup
# 0042 objtostring                            <calldata!mid:to_s, argc:0, FCALL|ARGS_SIMPLE>
# 0044 anytostring
# 0045 putobject                              " + "
# 0047 getlocal_WC_0                          b@1
# 0049 dup
# 0050 objtostring                            <calldata!mid:to_s, argc:0, FCALL|ARGS_SIMPLE>
# 0052 anytostring
# 0053 concatstrings                          4
# 0055 opt_send_without_block                 <calldata!mid:eval, argc:1, FCALL|ARGS_SIMPLE>
# 0057 leave
