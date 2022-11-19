# YARV
#### `compile.c`
- ASTをYARV命令列に変換する

#### `ruby/include/ruby/vm.h` / `ruby/vm.c`
- VMの内部構造

#### `tool/insns2vm.rb` / `tool/ruby_vm/scripts/insns2vm.rb`
- insns.defを読み込み、VMのために必要なファイルを生成する

#### insns.def
- VMの命令シーケンスの定義 (YARV命令がどのような命令であるか)

```c
DEFINE_INSN
instruction_name                 // 命令の名前
(type operand, type operand, ..) // オペランドの名前
(pop_values, ..)                 // 命令実行前にスタックからポップする値
(return values ..)               // 命令実行後にスタックにプッシュする値
// attr type name contents..     // 命令のカテゴリ、コメント
{
  ...                            // 命令のロジック
}
```

#### `vm_exec_core()` (`vm_exec.c`)
- YARV命令列を実行する関数
- make時にビルドディレクトリに生成される`vmtc.inc` (ラベルのエントリ) 、
  `vm.inc` (命令列のエントリ) をincludeする

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
- [YARV instruction dispatch](https://qiita.com/k0kubun/items/dbb2f0979f19f76eed26)
