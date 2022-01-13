{ 'key' => 'value', 1 => 2, :a => :b }

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,38)> (catch: FALSE)
# 0000 putobject                              "key"                     (   1)[Li]
# 0002 putstring                              "value"
# 0004 putobject_INT2FIX_1_
# 0005 putobject                              2
# 0007 putobject                              :a
# 0009 putobject                              :b
# 0011 newhash                                6
# 0013 leave
