# Makefile

```
# <ターゲット>: <ターゲットを生成するために必要なファイル>
#   <ターゲットを生成するためのコマンド>

prog.o: prog.c prog.h lib.h
  gcc -c prog.c

lib.o: lib.c lib.h
  gcc -c lib.c

prog: prog.o lib.o
  gcc prog.o lib.o -o prog
```

```
$ ls
lib.c   lib.h   prog.c  Makefile

# make <ターゲット名>
$ make prog
```

## 変数

```
# 変数のインライン化

CFLAGS = -Wall -Wextra -v

prog: prog.c
  gcc prog.c $(CFLAGS) -o prog
  # 変数を展開して gcc prog.c -Wall -Wextra -v -o prog が実行される
```

#### makeが保持する特殊変数

| 変数名   | 説明                                                                           |
| -        | -                                                                              |
| $$       | $記号                                                                          |
| $@       | 作成するファイルの名前                                                         |
| $?       | ターゲットより新しいファイルの名前                                             |
| $>       | ターゲットの全てのソースのリスト (GNU makeでは$^)                              |
| $<       | ターゲットオン変換元ファイルの名前                                             |
| $*       | ターゲットから先行のディレクトリコンポーネント・サフィックスを除いたファイル名 |

#### Makefileでよく使われるユーザー変数

| 変数名   | 説明                      |
| -        | -                         |
| CC       | Cコンパイラ               |
| CFLAGS   | Cコンパイル時のオプション |
| INCLUDES | ヘッダファイル            |
| INSTALL  | インストールプログラム    |
| LIBS     | 利用するライブラリ        |
| LFLAGS   | リンカのオプション        |
| OBJS     | オブジェクトファイル      |
| SHELL    | コマンドシェル            |
| SRCS     | ソースファイル            |

#### Makefileでよく使われる擬似ターゲット名

| 変数名   | 説明                                           |
| -        | -                                              |
| all      | ターゲットを全てビルドする                     |
| build    | ターゲットを全てビルドする                     |
| doc      | プロジェクトのドキュメントをビルドする         |
| depend   | 依存関係情報を生成する                         |
| test     | ビルド後の回帰テストを実行する                 |
| install  | インストール手順を実行する                     |
| clean    | ビルドプロセス中に生成されたファイルを削除する |
