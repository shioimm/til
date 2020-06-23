# Berkeley Packet Filter(BPF)
- 参照・引用: [Berkeley Packet Filter（BPF）入門（1）](https://www.atmarkit.co.jp/ait/articles/1811/21/news010.html)

## TL;DR
- ユーザーランドで作成したコードをカーネル内で安全に実行する枠組み
  - Linuxには諸々のイベントに対してBPFのプログラムをアタッチする仕組みがある
  - ユーザーは目的のBPFプログラムを作成することにより、カーネルの再コンパイルなしに
    該当のイベントに対するカーネルの動作を変更したり、ログを記録したりすることができる
- プログラムは独自の命令セットを持つ汎用カーネル内仮想マシン上で実行される

## 特徴
- BPFは汎用的な命令セットを持ち、
  カーネル内のヘルパー関数呼び出しを利用することにより
  様々な処理を実行可能となっている
- BPFは一部の機能を制限することにより、
  BPFプログラムで許可されていない動作を行わないことを保証することで
  プログラムを安全に実行することができる
- BPFはJITコンパイルをサポートしている

## 用途
- ネットワーキング
  - パケットフィルタリング
  - パケットフォワーディング
  - トンネリング
  - トラフィック制御
- トレーシング
  - カーネルトレーシング
  - ユーザープログラムトレーシング
  - パフォーマンスカウンタモニタリング
- セキュリティ
  - システムコールフィルタリング

## BPFを利用したプロジェクト
- BCC(BPF Compiler Collection)
- bpftrace、ply
- XDP(eXpress Data Path)
- Katran
- Cilium
- Landlock
- bpfilter

## cBPF / eBPF
- 従来BPFはカーネル内のパケットフィルタリング機構として利用されてきた
  - cBPF(classic BPF)
- 現在のLinuxのBPFはパケットフィルタリング以外にも
  様々な箇所でカーネル内の操作をフックしてプログラムを実行するための手法として用いられる
  - eBPF(extend BPF)
  - 命令セットが一新され、使用可能なレジスタ数が増え、ヘルパー関数呼び出しの機能が追加された

## BCC(BPF Compiler Collection)
- 参照: [iovisor/bcc](https://github.com/iovisor/bcc)
- 参照・引用: [BCC（BPF Compiler Collection）によるBPFプログラムの作成](https://www.atmarkit.co.jp/ait/articles/1912/17/news006.html)
- 効率的なカーネルトレースと操作プログラムを作成するためのツールキット
  - eBPFを使用している
  - パフォーマンス解析やネットワークトラフィック制御などの用途に適している
- C(LLVMによるCラッパーを含む)によるカーネルインストルメンテーションと
  Python・luaによるフロントエンドにより、 BPFプログラムをより簡単に書くことができる

### BCCの機能
- BPFプログラムを簡単に記述するためのModified C(BPF C)
- BPF Cのコンパイル機能
- BPFプログラムローダー
  - LLVM/Clangを用いてBPF CのASTを解析/変更した上でBPFプログラムにコンパイルし、カーネルにロードする
- BPFマップへアクセスするための関数
