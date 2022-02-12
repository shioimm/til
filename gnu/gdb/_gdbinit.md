# .gdbinit
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

## 参照
- 独習アセンブラ
- Webで使えるmrubyシステムプログラミング入門
- はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
