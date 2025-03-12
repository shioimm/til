# yacc
- パーサジェネレータ
- 文法ファイルに記述された構文規則に基づくLALR構文解析を行うCプログラムを生成する
- 文法ファイルはBNF (Backus-Naur Form) によって記述する
- yaccで作ったパーサはLALR機能を持つ
  - シフトや還元をする前に次の記号を一つだけ見てどうするかを判断する
- bison = GNUのyacc

## 参照
- [yacc](https://ja.wikipedia.org/wiki/Yacc)
- [第9章 速習yacc](https://i.loveruby.net/ja/rhg/book/yacc.html)
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- コンパイラ入門 構文解析の原理とlex/yacc, C言語による実装
