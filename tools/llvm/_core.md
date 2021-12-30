# LLVM Core
- コンパイラ基盤
- 任意のプログラミング言語から任意のプロセッサに対応する機械語へのコンパイル、
  その際の中間言語の最適化処理をサポートする

#### 動作フロー
- フロントエンド -> (LLVM IR) -> LLVMオプティマイザ -> (LLVM IR) -> バックエンド
  - フロントエンド: 各プログラム言語の解析を行う
  - オプティマイザ: 最適化を行う
  - バックエンド: 各プロセッサ向けの機械語を出力する
  - LLVM IR: 中間表現

## 参照
- [The LLVM Compiler Infrastructure](https://llvm.org/)
- [LLVMとは](https://dev.classmethod.jp/articles/about_llvm/)
