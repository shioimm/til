# リンク
### スタティックライブラリ
```
# オブジェクトファイルをアーカイブファイルにまとめる
$ ar -rcs liblib.a lib.o

# ヘッダファイルの格納場所とアーカイブファイルの格納場所を指定
$ gcc prog.c -I /path/to/header -L /path/to/archive -llib -o prog
```

### ダイナミックリンク
```
# ヘッダファイルの格納場所を指定してオブジェクトファイルを作成
# gcc -I/path/to/header -c lib.c -o lib.o

# オブジェクトファイルから共有ファイルを作成
$ gcc -shared lib.o -o /path/to/liblib.so

$ gcc prog.c -L/path/to/ -llib -o main

# Linuxの場合
# $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to
```
