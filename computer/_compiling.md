# コンパイル方式
#### JIT
- ソフトウェアの実行プロセス起動後、
  ソースコード中の実行対象の部分の中間コードを実行する直前にマシン語へ変換し、マシン上で直接実行する
- e.g. ソースコード -> AST -> バイトコード -> (一部ずつ) マシン語 -> マシン上で実行
- e.g. ソースコード -> AST -> (一部ずつ) マシン語 -> マシン上で実行

#### 事前コンパイル方式 (AOT: Ahead-Of-Time)
- ソフトウェアの実行プロセス起動前にソースコード全体を中間コードから機械語へ変換する
- e.g. ソースコード -> AST -> バイトコード -> マシン語 -> マシン上で実行

#### インタプリタ方式
- ソフトウェアの実行プロセス中にASTを辿りながらコードを実行する (実行のコスト + 木の巡回コスト)
- e.g. ソースコード -> AST -> 実行

#### VMを利用する方式
- ソフトウェアの実行プロセス起動後、中間コードをVM上で実行する
- e.g. ソースコード -> AST -> バイトコード -> VM上で実行

## 参照
- [実行時コンパイラ](https://ja.wikipedia.org/wiki/%E5%AE%9F%E8%A1%8C%E6%99%82%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9)
- [JITあれこれ](https://keens.github.io/blog/2018/12/01/jitarekore/)