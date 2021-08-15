# LLVM
- コンパイラを開発するための基盤となるソフトウェアを開発するオープンソースプロジェクト
  - コンパイラ作成のためのライブラリやツールチェーン技術の集合体
- SSAによるコンパイルストラテジーを提供する

### SSA(静的単一代入)
- コンパイラ設計における 中間表現のひとつ
- 各変数が一度のみ代入されるよう定義されたもの
- [静的単一代入](https://ja.wikipedia.org/wiki/%E9%9D%99%E7%9A%84%E5%8D%98%E4%B8%80%E4%BB%A3%E5%85%A5)

## 動作フロー
1. Clangを用いてC/C＋＋/Objective-Cなどをソースコードとして読み込む
2. LLVM IR(実行環境に依存しない中間表現)を生成
    - この際、言語・環境とは独立した最適化を行う
3. LLVM IRから様々な動作基盤に最適化されたバイナリを生成

## 主なサブプロジェクト
- LLVM Core
- [Clang](http://clang.llvm.org/)
  - C言語ファミリー向けのコンパイラフロントエンド(<-> gcc)
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

## 参照・引用
- [The LLVM Compiler Infrastructure](https://llvm.org/)
- [LLVM](https://ja.wikipedia.org/wiki/LLVM)
- [雑把の仮想マシン(JVM, .NET, BEAM, スクリプト言語, LLVM)](http://yohshiy.blog.fc2.com/blog-entry-238.html)
- [WebAssemblyに正式対応した「LLVM 8.0」がリリース](https://www.publickey1.jp/blog/19/webassemblyllvm_80.html)
