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
# オブジェクトファイルとをアーカイブファイルにまとめる
# lib1.o + lib2.o -> liblib.a
$ ar -rcs liblib.a lib1.o lib2.o

# prog.c + liblib.a -> prog
$ gcc prog.c -llib -o prog

# (アーカイブファイル/path/to/archivesの格納場所を指定)
$ gcc prog.c -L/path/to/archives -llib -o prog

# (ヘッダファイルの格納場所/path/to/headersとアーカイブファイル/path/to/archivesの格納場所を指定)
$ gcc prog.c -I/path/to/headers -L/path/to/archives -llib -o prog

# 実行
$ ./prog
```

#### 共有オブジェクトファイルとのダイナミックリンク
```
# 位置独立なオブジェクトファイルを作成 (デフォルト)
# lib.c -> lib.o
# gcc (-fPIC) -c lib.c -o lib.o

# オブジェクトファイルから共有オブジェクトファイルを作成
# lib.o -> /path/to/liblib.so
$ gcc -shared lib.o -o /path/to/liblib.so    # Linuxの場合
$ gcc -shared lib.o -o /path/to/liblib.dylib # macOSの場合

# コンパイル
# prog.c + /path/to/liblib.so (.dylib) -> prog
$ gcc prog.c -L/path/to/ -llib -o prog

# Linuxの場合
# $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to

# 実行
$ ./prog
```

## 参照
- [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)
