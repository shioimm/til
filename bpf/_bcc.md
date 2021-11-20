# BCC (BPF Compiler Collection)
- 効率的なカーネルトレースと操作プログラムを作成するためのツールキット
  - eBPFを使用している
  - パフォーマンス解析やネットワークトラフィック制御などの用途に適している
- C(LLVMによるCラッパーを含む)によるカーネルインストルメンテーションと
  Python・luaによるフロントエンドにより、 BPFプログラムをより簡単に書くことができる

## BCCの機能
- BPFプログラムを簡単に記述するためのModified C (BPF C)
- BPF Cのコンパイル機能
- BPFプログラムローダー
  - LLVM/Clangを用いてBPF CのASTを解析/変更した上でBPFプログラムにコンパイルし、カーネルにロードする
- BPFマップへアクセスするための関数

## 参照
- [iovisor/bcc](https://github.com/iovisor/bcc)
- [BCC（BPF Compiler Collection）によるBPFプログラムの作成](https://www.atmarkit.co.jp/ait/articles/1912/17/news006.html)
