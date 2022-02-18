# valgrind
- メモリに関するプログラムの挙動をトレースするデバッグツール
- プログラム終了時に、ヒープ領域中に確保されたブロックがroot-setから辿れるかどうかをチェックする

### Memcheck
```
# 実行ファイルにデバッグ情報を付加しておく
$ gcc -g prog.c -o prog

$ valgrind --leak-check=full ./prog
```

- メモリの解放忘れ
- 不正なメモリの読み書き
- 初期化していない値の利用
- 操作対象のメモリ領域のオーバーラップ
- メモリアロケーションと解放のミスマッチ (C++)

#### LEAK SUMMARY
- definitely lost
  - 直接アクセスできる未解放の領域がある
- indirectly lost
  - 直接アクセスできる未解放の領域があり、更にその先にもまだ未解放の領域がある
- possibly lost
  - malloc/newで確保された領域の内の先頭以外のアドレスが参照されている
- still reachable
  - 解放されるべきメモリが何かしらの理由でされていない
- suppressed
  - リークエラーが抑制されている

### cachegrind
- プログラムのCPUの例や別のキャッシュヒット率を分析する

```
$ valgrind --tool=cachegrind ./prog
```

### helgrind
- マルチスレッドプログラムのエラーを分析する

```
$ valgrind --tool=helgrind ./prog
```

## massif
- ヒープの利用状況を分析する

```
$ valgrind --tool=massif ./prog # => massif.out.<pid>ファイルが出力される

# 分析結果を出力
$ ms_print massif.out.<pid>
```

## 参照
- [Valgrind](https://valgrind.org/)
- [Valgrind Frequently Asked Questions](https://www.valgrind.org/docs/manual/faq.html)
- [valgrindが検出するメモリリークの種類](https://www.wagavulin.jp/entry/2016/08/28/231547)
- Webで使えるmrubyシステムプログラミング入門 Section024
