# C
```
$ gcc prog.c -o prog # ソースファイルから実行ファイルを生成
$ gcc -c prog.c      # オブジェクトファイル (prog.o) を生成
$ gcc prog.o -o prog # オブジェクトファイルから実行ファイルを生成 (リンク)
```

#### 複数ソースファイルのコンパイル
```
$ ls
lib.c   lib.h   prog.c

$ gcc prog.c lib.c -o prog

$ ./prog
```

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

#### makeによる実行ファイルの生成
```
prog.o: prog.c lib.h
  gcc -c prog.c

lib.o: lib.c lib.h
  gcc -c lib.c

prog: prog.o lib.o
  gcc prog.o lib.o -o prog
```

```
$ ls
lib.c   lib.h   prog.c

$ make prog
```
