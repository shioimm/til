# Clang
- C、C++、Objective-C、Objective-C++、OpenCL、CUDA向けのコンパイラフロントエンド
- フロントエンドClang + バックエンドLLVMで動作する
  - LLVM 2.6以降、ClangはLLVMの一部としてリリースされている
  - ClangプロジェクトはGCCを置き換えることのできるコンパイラを提供することを目標とする
  - Clang + LLVMの組み合わせによりGCCツールチェインの大半の機能を提供し、GCCの置き換えが可能となる
- コンパイル中にGCCよりも多くの情報を取得し、得られた情報を元のコードと同じ形態で保存する

## 参照
- [Clang: a C language family frontend for LLVM)](https://clang.llvm.org/)
