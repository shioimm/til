# valgrind
- 参照: [Valgrind](https://valgrind.org/)
- 参照: [Valgrind Frequently Asked Questions](https://www.valgrind.org/docs/manual/faq.html)
- 参照: [valgrindが検出するメモリリークの種類](https://www.wagavulin.jp/entry/2016/08/28/231547)
- 参照: []()

## TL;DR
- メモリに関するプログラムの挙動をトレースするデバッグツール
  - メモリの割り当て、メモリ解放のタイミングetc
- プログラム終了時に、ヒープ領域中に確保されたブロックがroot-setから辿れるかどうかをチェックする

## Usage
```
$ valgrind --leak-check=full ./実行するバイナリ
```

### LEAK SUMMARY
- `definitely lost`
  - 直接アクセスできる未解放の領域がある
- `indirectly lost`
  - 直接アクセスできる未解放の領域があり、更にその先にもまだ未解放の領域がある
- `possibly lost`
  - malloc/newで確保された領域の内の先頭以外のアドレスが参照されているということ
- `still reachable`
  - 解放されるべきメモリが何かしらの理由でされていない
- `suppressed`
  - リークエラーが抑制されていること
