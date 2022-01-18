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

### コンパイルオプション
- `:inline_const_cache` - - 定数インラインキャッシュを利用する (デフォルトで有効)
- `:instructions_unification` - スタックキャッシングを行う
- `:operands_unification` - オペランド融合を行う
- `:peephole_optimization` - ピープホール最適化を行う (デフォルトで有効)
- `:specialized_instruction` - 特化命令を利用する (デフォルトで有効)
- `:stack_caching` - スタックキャッシングを行う
- `:tailcall_optimization`
- `:trace_instruction`

## Rubyファイルの実行フロー
1. 実行ファイルの読み込み
2. 字句解析
3. 構文解析
4. YARV命令列の生成
5. YARV命令列の実行

## 参照
- [YARVアーキテクチャ](http://www.atdot.net/yarv/yarvarch.ja.html)
- [YARV Maniacs 【第 8 回】 命令列のシリアライズ](https://magazine.rubyist.net/articles/0015/0015-YarvManiacs.html)
