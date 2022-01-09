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

## 参照
- [YARVアーキテクチャ](http://www.atdot.net/yarv/yarvarch.ja.html)
