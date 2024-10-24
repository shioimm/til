# ビルドプロセス
1. ソースファイル`.c`の作成
2. プリプロセッシング (プリプロセッサ)
    - プリプロセッサディレクティブ (e.g. #include / #define) の解決
    - コメントの削除
3. コンパイル (コンパイラ)
    - ソースファイル`.c` -> アセンブリ言語によるファイル`.asm`
4. アセンブル (アセンブラ)
    - アセンブリ言語によるファイル`.asm` -> オブジェクトファイル`.o`
5. リンク (リンカ)
    - オブジェクトファイル`.o` -> 実行ファイル

## リンク
#### 静的リンク (スタティックリンク)
- ライブラリを事前にコンパイルしてオブジェクトコードの状態にしておき、
  コンパイル時にリンクを行うことでライブラリ内の関数をプログラムに組み込む方式
- 静的リンクライブラリはオブジェクトファイルをまとめたアーカイブファイル (.a) として配布される

```
# ヘッダファイル (lib.h) をCプログラムに#include
# ライブラリ (liblib.a) の格納場所をコンパイル時に指定してコンパイル

$ gcc prog.c -I /path/to/lib.hを格納したディレクトリ -L /path/to/liblib.aを格納したディレクトリ -l lib
```

#### 動的リンク (ダイナミックリンク)
- ライブラリを事前に共有ライブラリとして作成しておき、
  リンク時に使用するライブラリと関数の情報だけをプログラムに組み込む方式
- プログラムの起動時または実行時に使用するライブラリをメモリ上にロードし、プログラムはその中の関数を呼び出す

```
# ヘッダファイル (lib.h) をCプログラムに#include
# ライブラリ (liblib.so) の格納場所をコンパイル時に指定してコンパイル

$ gcc prog.c -I /path/to/lib.hを格納したディレクトリ -L /path/to/liblib.soを格納したディレクトリ -l lib
```

## 参照
- [C/C++のビルドの仕組みとライブラリ](https://kamino.hatenablog.com/entry/c%2B%2B-principle-of-build-library)
