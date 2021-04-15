# LLVM
- 参照・引用: [The LLVM Compiler Infrastructure](https://llvm.org/)
- 参照・引用: [LLVM](https://ja.wikipedia.org/wiki/LLVM)
- 参照: [雑把の仮想マシン(JVM, .NET, BEAM, スクリプト言語, LLVM)](http://yohshiy.blog.fc2.com/blog-entry-238.html)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## TL;DR
- コンパイラ基盤
  - コンパイラ作成のためのライブラリやツールチェーン技術の集合体
  - コンパイル時、リンク時、実行時などあらゆる時点でプログラムを最適化するよう設計されている
- 任意のプログラミング言語による静的/動的コンパイルに対応している

## 特徴
- コンパイル時、仮想機械をターゲットとした中間コードを生成した後、
  中間コードを特定のマシンの機械語に変換する
  - この際、言語・環境とは独立した最適化を行う
- SSAによるコンパイルストラテジーを提供する
  - SSA(静的単一代入):
    - コンパイラ設計における 中間表現のひとつ
    - 各変数が一度のみ代入されるよう定義されたもの
    - 参照: [静的単一代入](https://ja.wikipedia.org/wiki/%E9%9D%99%E7%9A%84%E5%8D%98%E4%B8%80%E4%BB%A3%E5%85%A5)

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
