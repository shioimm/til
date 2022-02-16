# リンク
#### 複数オブジェクトファイルのリンク
```
$ ls
lib.c   lib.h   prog.c

# オブジェクトファイルの生成
$ gcc -c prog.c lib.c

# オブジェクトファイルのリンク
$ gcc prog.o lib.o -o prog

$ ./prog
```

#### アーカイブファイルとのスタティックリンク
```
# オブジェクトファイルをアーカイブファイルにまとめる
$ ar -rcs liblib.a lib.o

# ヘッダファイルの格納場所とアーカイブファイルの格納場所を指定
$ gcc prog.c -I /path/to/header -L /path/to/archive -llib -o prog
```

#### 共有ファイルとのダイナミックリンク
```
# ヘッダファイルの格納場所を指定してオブジェクトファイルを作成
# gcc -I/path/to/header -c lib.c -o lib.o

# オブジェクトファイルから共有ファイルを作成
$ gcc -shared lib.o -o /path/to/liblib.so

$ gcc prog.c -L/path/to/ -llib -o main

# Linuxの場合
# $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to
```

## 参照
- [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)
