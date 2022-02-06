# C
## 代入
- 代入はデータのコピーを行う

```c
int a = 1;
int b = a;   // aの値1のコピー
int *c = &a;
int *d = c;  // aのアドレスのコピー

printf("%i\n", a); // 1
printf("%i\n", b); // 1
printf("%p\n", c); // 0x7ffc22dd5d28
printf("%p\n", d); // 0x7ffc22dd5d28
```

## コンパイル
```
$ gcc prog.c -o prog # ソースファイルから実行ファイルを生成
$ gcc -c prog.c      # オブジェクトファイル (prog.o) を生成
$ gcc prog.o -o prog # オブジェクトファイルから実行ファイルを生成 (リンク)
$ gcc -g proc.c      # ソースファイルからデバッグ情報を追加した実行ファイルを生成
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
