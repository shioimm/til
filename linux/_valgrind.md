# valgrind
- 参照: [Valgrind](https://valgrind.org/)
- 参照: [Valgrind Frequently Asked Questions](https://www.valgrind.org/docs/manual/faq.html)
- 参照: [valgrindが検出するメモリリークの種類](https://www.wagavulin.jp/entry/2016/08/28/231547)

## TL;DR
- メモリに関するプログラムの挙動をトレースするデバッグツール
  - メモリの割り当て、メモリ解放のタイミングetc
- プログラム終了時に、ヒープ領域中に確保されたブロックがroot-setから辿れるかどうかをチェックする

## Usage
```
$ valgrind --leak-check=full ./実行するバイナリ
```

### LEAK SUMMARY
- `definitely lost` (要修正)
  - プログラムがリークしているメモリの情報
- `indirectly lost` (`definitely lost`を修正)
  - プログラムがポインタベースの構造体でリークしているメモリの情報
- `possibly lost` (要修正)
  - malloc/newで確保された領域の内の先頭以外のアドレスが参照されているということ
- `still reachable` (修正不要)
  - プログラム終了時にヒープ領域にデータが残っており、root-set辿れる状態にあるということ
- `suppressed`
  - リークエラーが抑制されていること
