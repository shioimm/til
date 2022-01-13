{ foo: { bar: 1 } }.dig(*[:foo, :bar])

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,38)> (catch: FALSE)
# 0000 putobject                              :foo                      (   1)[Li]
# 0002 duphash                                {:bar=>1}
# 0004 newhash                                2
# 0006 duparray                               [:foo, :bar]
# 0008 opt_send_without_block                 <calldata!mid:dig, argc:1, ARGS_SPLAT>
# 0010 leave
