# leak-check

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

#### LEAK SUMMARY:
- definitely lost
  - 変数に確保したまま未解放になっている領域
- indirectly lost
  - 変数に確保したまま未解放になっている領域 + 構造体のメンバとして確保したまま未解放になっている領域
- possibly lost
  - 追跡できなくなった領域 (割り当てされたメモリの始点を指すポインタが消失している状態)
- still reachable
  - 解放される前にプログラムがabortしたため未解放になっている領域
- suppressed
  - リークエエラーの検出を抑制された領域

#### HEAP SUMMARY:
- 領域が確保された際のバックトレースを表示
