# Clang
- LLVM上で動作することを意図して設計されたコンパイラフロントエンド
  - C、C++、Objective-C、Objective-C++、OpenCL、CUDAのフロントエンドの提供を行う
  - ClangプロジェクトはGCCを置き換えることのできるコンパイラを提供することを目標とする
  - ClangとLLVMの組み合わせにより、ツールチェインの大半の機能を提供し、
    GCCスタック全体の置き換えが可能となる
  - コンパイル中にGCCよりも多くの情報を取得し、得られた情報を元のコードと同じ形態で保存する

## 参照
- [Clang: a C language family frontend for LLVM)](https://clang.llvm.org/)
