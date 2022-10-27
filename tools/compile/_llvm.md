# LLVM (Core)
- コンパイラバックエンド
- コンパイルフロントエンド (Clang) が生成する中間言語を対象のアーキテクチャに最適なマシン語へ変換する

#### 動作フロー

```
(各言語による) ソースプログラム -> フロントエンド -> (IR) -> オプティマイザ -> (IR) -> バックエンド
```

1. フロントエンドがソースプログラムを中間表現またはIRに変換する
    - フロントエンド: 各プログラム言語の解析を行う
2. オプティマイザがIRをIRへ変換する
    - オプティマイザ: 最適化を行う
    - LLVM IR: 中間表現
    - LLVMでは全プロセスを通じてプログラムが同じIRを使う
3. バックエンドがIRを機械語へ変換する
    - バックエンド: 各プロセッサ向けの機械語を出力する

## LLVM IRの構成
- モジュールは関数群から構成される
  - モジュール: ソースファイル / トランスレーションユニット
- 関数は基本ブロックから構成される
  - 基本ブロック: 連続した命令群
- 基本ブロックは命令から構成される
  - 命令: 単一コードの演算子 (アセンブリ言語と同程度の抽象度)
- モジュール以外のものは値から枝分かれする
  - 値: 基底クラスから継承するC++のクラス、計算に使える値

## LLVM Core以外のLLVMプロジェクト
- [LLVM Core](https://llvm.org/doxygen/group__LLVMCCore.html)
- [Clang](http://clang.llvm.org/)
  - C言語ファミリーのLLVMフロントエンド (<-> gcc)
- [LLDB](http://lldb.llvm.org/)
- [libc++](http://libcxx.llvm.org/) / [libc++ ABI](http://libcxxabi.llvm.org/)
  - 標準C++ライブラリ
- [compiler-rt](http://compiler-rt.llvm.org/)
- [MLIR](https://mlir.llvm.org/)
- [OpenMP](http://openmp.llvm.org/)
- [Polly](http://polly.llvm.org/)
- [libclc](http://libclc.llvm.org/)
- [KLEE](http://klee.github.io/)
- [LLD](http://lld.llvm.org/)

## 参照
- [The LLVM Compiler Infrastructure](https://llvm.org/)
- [雑把の仮想マシン(JVM, .NET, BEAM, スクリプト言語, LLVM)](http://yohshiy.blog.fc2.com/blog-entry-238.html)
- [WebAssemblyに正式対応した「LLVM 8.0」がリリース](https://www.publickey1.jp/blog/19/webassemblyllvm_80.html)
- [LLVMとは](https://dev.classmethod.jp/articles/about_llvm/)
- [大学院生のためのLLVM](https://postd.cc/llvm-for-grad-students/)
