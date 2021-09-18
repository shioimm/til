## Usage
1. 起動 - デバッグする対象のバイナリをフルパスで指定
2. ブレークポイントを設定 - ブレークポイントを設定したい関数を指定
3. コードを実行
4. 対象のバイナリの行番号を指定して実行
5. バックトレースを表示
6. プログラムの停止箇所を表示
7. printデバッグ
8. ステップ実行
9. gdbを終了
10. 実行中のプロセスにアタッチ
```
$ gdb /usr/bin/ruby

(gdb) break rb_inspect
(gdb) run -e 'p C.from_mruby'
(gdb) run -n 5
(gdb) backtrace
(gdb) list
(gdb) print xxxx
(gdb) next
(gdb) step # 別の関数に入った場合はその関数でもステップ実行
(gdb) quit

$ gdb -p デバッグするプロセスID
```

## .gdbinit
1. `main`関数にブレークポイントを指定
2. レジスタEAX、EBX、ESIの値を16進数表記で表示
3. プログラムカウンタが指すアドレスから4命令を逆アセンブル(オブジェクトコード->アセンブリ言語のソースコード)
```
break *main
display /x $eax
display /x $ebx
display /x $esi
display /4i $pc
```

- .gdbinitファイル読み込み時の警告を消す
```
// $HOME/.gdbinit
set auto-load safe-path /
```

1. プログラムを実行(run)
2. プログラムカウンタの値を表示(print)
3. レジスタECXの値を10進数で表示
4. レジスタECXの値を16進数で表示
5. レジスタECXの値を8進数で表示
6. レジスタECXの値を2進数で表示
7. レジスタEAXの値を書き換え
8. レジスタESP(スタックポインタ)の指すメモリアドレスに格納されている内容をバイト単位で32個表示
9. スタックの一番上の4バイトを32ビット符号付き整数の0で上書き
10. プログラムの実行を継続(continue)
```
$ gdb -q add
(gdb) r
(gdb) p $pc
(gdb) p $ecx
(gdb) p/x $ecx
(gdb) p/o $ecx
(gdb) p/t $ecx
(gdb) set $eax=123
(gdb) x/32b $esp
(gdb) set *(0xffffd4ec) = 0
(gdb) c
```

- プログラムをステップ実行(stepi)
```
$ gdb -q add
(gdb) r
(gdb) si
```

## TUI(Text User Interface)
1. TUIに切り替える
2. 逆アセンブル結果を表示する
3. レジスタの値を表示する
4. ソースコードを表示する
5. CLIに切り替える
```
(gdb) tui enable
(gdb) layout asm
(gdb) layout regs
(gdb) layout src
(gdb) tui disable
```

## 参照
- 独習アセンブラ
- Webで使えるmrubyシステムプログラミング入門
