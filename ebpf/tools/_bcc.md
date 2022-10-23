# bcc (BPF Compiler Collection)
- BPFプログラムを書くためのフロントエンドツールキット
- C (LLVMによるCラッパーを含む) によるカーネルインストルメンテーションと
  Python・Lua・Goによるバインディングを備える

#### bcc tools
- bccを使ったトレーシングのツールキット
  - e.g. execsnoop - execve(2)をトレースする
  - e.g. bashreadline - bashに入力されたコマンドを表示する
  - e.g. argdict - 指定の関数をトレースし引数の値を頻度カウンタやヒストグラムとして表示する

## bccの機能
- BPFプログラムを簡単に記述するためのModified C (BPF C)
- BPF Cのコンパイル機能
- BPFプログラムローダー
  - LLVM/Clangを用いてBPF CのASTを解析/変更した上でBPFプログラムにコンパイルし、カーネルにロードする
- BPFマップへアクセスするための関数

## 参照
- [iovisor/bcc](https://github.com/iovisor/bcc)
- [BCC（BPF Compiler Collection）によるBPFプログラムの作成](https://www.atmarkit.co.jp/ait/articles/1912/17/news006.html)
