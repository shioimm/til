# YARV
- 仮想マシン - ソフトウェア上で実装された「CPUの中にあるCPU」

#### YRVによるコード実行
1. コードを解釈する
2. コードが一連のVMインストラクションに変換する
3. VMインストラクションがYARVに送り込まれる
4. VMインストラクションがCPUインストラクションに変換される
5. CPUインストラクションが実行される

#### `compile.c`
- ASTをYARV命令列に変換する
- `iseq_compile_each()`が呼び出す`iseq_compile_each0()`でノードの種類を取得し、
  `switch`文を用いてノードの種類ごとに`compile_*()`を呼び出す
  - メソッド呼び出しを表すノードでは`compile_call()`が呼び出され、
    スタックにレシーバと引数をプッシュした後`ADD_SEND_R`マクロを呼び出してYRAVのSEND命令を実行する

#### `build/vm.inc` `build/vmtc.inc`
- YARV命令列を実行するVM

#### `ruby/include/ruby/vm.h` / `ruby/vm.c`
- VMの内部構造の定義

#### `tool/insns2vm.rb` / `tool/ruby_vm/scripts/insns2vm.rb`
- VM Generator
- insns.defを読み込み、VMが命令を実行するために必要なファイルを生成する

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

## 参照
- [YARVアーキテクチャ](http://www.atdot.net/yarv/yarvarch.ja.html)
- [YARV Maniacs 【第 8 回】 命令列のシリアライズ](https://magazine.rubyist.net/articles/0015/0015-YarvManiacs.html)
- [YARV instruction dispatch](https://qiita.com/k0kubun/items/dbb2f0979f19f76eed26)
