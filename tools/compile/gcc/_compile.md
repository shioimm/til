## コンパイル
```
# ソースファイルprog.c -> 実行ファイルprog
$ gcc prog.c -o prog

# (ヘッダファイルの格納場所/path/to/prog.hを追加指定)
$ gcc -I/path/to/prog.h prog.c -o prog

# ソースファイルprog.c -> オブジェクトファイルprog.o (リンクを行わない)
$ gcc -c prog.c

# オブジェクトファイルprog.o -> 実行ファイルprog (リンクを行う)
$ gcc prog.o -o prog

# ソースファイルprog.c -> デバッグ情報を追加した実行ファイルprog
$ gcc -g proc.c
```

#### 複数ソースファイルのコンパイル
```
# ソースファイルprog.c + ソースファイルlib.c -> 実行ファイルprog
$ gcc prog.c lib.c -o prog
```

#### 出力
```
# 冗長
$ gcc prog.c -v

# 警告を表示
$ gcc prog.c -Wall
```

#### 位置独立
```c
# 位置非依存のコードを生成しない
$ gcc prog -fno-pic

$ gcc prog -fpic
# 位置非依存のコードを生成する
```

#### フレームポインタ
```c
# フレームポインタを管理するコードを生成しない
$ gcc prog -fomit-frame-pointer
```

## 参照
- [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)