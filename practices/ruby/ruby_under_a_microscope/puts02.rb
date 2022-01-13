p "a" + "b"

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,11)> (catch: FALSE)
# 0000 putself                                                          (   1)[Li]
# 0001 putstring                              "a"
# 0003 putstring                              "b"
# 0005 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
# 0007 opt_send_without_block                 <calldata!mid:p, argc:1, FCALL|ARGS_SIMPLE>
# 0009 leave
