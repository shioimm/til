# YARV
#### `ruby/include/ruby/vm.h` / `ruby/vm.c`
- VMの内部構造

#### `tool/insns2vm.rb` / `tool/ruby_vm/scripts/insns2vm.rb`
- insns.defファイルを読み込み、VMのために必要なファイルを生成する

#### insns.def
- VMの命令シーケンスの定義 (YARV命令がどのような命令であるか)

```c
DEFINE_INSN
instruction_name
(type operand, type operand, ..)
(pop_values, ..)
(return values ..)
// attr type name contents..
{
  .. // insn body
}
```

#### leave命令
- leaveが呼ばれる直前までに積まれているスタックトップを持って前のスコープに戻る

## RubyVM::InstructionSequence
```ruby
source = "puts 'called'"
puts RubyVM::InstructionSequence.compile(source).disasm

# == disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,13)> (catch: FALSE)
# 0000 putself                                                          (   1)[Li]
# 0001 putstring                              "called"
# 0003 opt_send_without_block                 <calldata!mid:puts, argc:1, FCALL|ARGS_SIMPLE>
# 0005 leave
```

- 命令番地
- 命令名
- 命令オペランド
  - mid  - メソッド
  - argc - 引数数
- 行番号

## 参照
- [YARVアーキテクチャ](http://www.atdot.net/yarv/yarvarch.ja.html)
