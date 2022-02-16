## コンパイル
```
$ gcc prog.c -o prog # ソースファイルから実行ファイルを生成
$ gcc -c prog.c      # オブジェクトファイル (prog.o) を生成 (リンクを行わない)
$ gcc prog.o -o prog # オブジェクトファイルから実行ファイルを生成 (リンク)
$ gcc -g proc.c      # ソースファイルからデバッグ情報を追加した実行ファイルを生成

$ gcc prog.c -v      # 冗長
$ gcc prog,c -Wall   # 警告を表示

$ gcc prog -fno-pic  # 位置非依存のコードを生成しない
$ gcc prog -fpic     # 位置非依存のコードを生成する
$ gcc prog -fomit-frame-pointer # フレームポインタを管理するコードを生成しない
$ gcc -I/path/to/lib.o prog.c /path/to/lib.o -o prog # ヘッダファイルの格納場所を追加で指定
```

#### 複数ソースファイルのコンパイル
```
$ ls
lib.c   lib.h   prog.c

$ gcc prog.c lib.c -o prog

$ ./prog
```

## 参照
- [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)
