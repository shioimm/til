# RubyVM::InstructionSequence

```ruby
source = "puts 1 "
puts RubyVM::InstructionSequence.compile(source).disasm

# 命令番地 / 命令名 / 命令オペランド (mid (メソッド) / (argc (引数数)) / 行番号

== disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,10)> (catch: FALSE)
0000 putself                                                          (   1)[Li]
0001 putobject_INT2FIX_1_
0002 putobject                              2
0004 opt_plus                               <calldata!mid:+, argc:1, ARGS_SIMPLE>[CcCr]
0006 opt_send_without_block                 <calldata!mid:puts, argc:1, FCALL|ARGS_SIMPLE>
0008 leave
```


### コンパイルオプション
- `:inline_const_cache`       - 定数インラインキャッシュを利用する (デフォルトで有効)
- `:instructions_unification` - スタックキャッシングを行う
- `:operands_unification`     - オペランド融合を行う
- `:peephole_optimization`    - ピープホール最適化を行う (デフォルトで有効)
- `:specialized_instruction`  - 特化命令を利用する (デフォルトで有効)
- `:stack_caching`            - スタックキャッシングを行う
- `:tailcall_optimization`
- `:trace_instruction`
