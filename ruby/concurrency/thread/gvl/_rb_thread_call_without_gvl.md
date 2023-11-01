# `rb_thread_call_without_gvl` / `rb_thread_call_without_gvl2`
- include/ruby/thread.h / thread.c

#### `rb_thread_call_without_gvl`
- 関数`void *(*func)(void *)`を他のRubyスレッドと並列に実行する
- 他のスレッドから`rb_thread_kill`などされた場合UBFを実行する
- シグナルによる割り込みにも反応する
- `void *(*func)(void *)` が終了後に割り込みを受けた場合は割り込みチェックを省略できる

```c
void *rb_thread_call_without_gvl(
  void *(*func)(void *),      // GVLなしで実行する関数
  void *data1,                // GVLなしで実行する関数の引数
  rb_unblock_function_t *ubf, // UBF (GVLなしで実行する関数をキャンセルする関数)
  void *data2                 // UBFの引数
);
```

1. 保留中の割り込みをチェックし、割り込みがある場合は処理する
    - 割り込みのチェック = 非同期割り込みイベントをチェックし、対応する手続きを呼び出す
2. GVLを解放する (これにより、他のRubyスレッドはここで並行して実行可能)
3. 関数`void *(*func)(void *)`を呼び出す
4. GVLを再取得するまでブロック
    - ブロック中に割り込みを捕捉した場合はUBF (`rb_unblock_function_t *ubf`) を実行して実行を中断
    - 中断された場合、2..4の間に起こった割り込みをチェックし、割り込みがある場合は処理する
5. GVLを取得 (これにより、他のRubyスレッドは並列に実行不可能になる)
6. `void *(*func)(void *)`の返り値 (中断された場合は0) を返す

#### `rb_thread_call_without_gvl2`
- `rb_thread_call_without_gvl`と大体同じ
- シグナルによる割り込みに反応しない
- 割り込みを検出した場合は即座に返る

```c
void *rb_thread_call_without_gvl2(
  void *(*func)(void *),      // GVLなしで実行する関数
  void *data1,                // GVLなしで実行する関数の引数
  rb_unblock_function_t *ubf, // UBF (GVLなしで実行する関数をキャンセルする関数)
  void *data2                 // UBFの引数
);
```

1. 保留中の割り込みをチェックし、割り込みがある場合は割り込みを処理せず即座に返る
2. GVLを解放する (これにより、他のRubyスレッドはここで並行して実行可能)
3. 関数`void *(*func)(void *)`を呼び出す
4. GVLを再取得するまでブロック
    - ブロック中に割り込みを捕捉した場合はUBF (`rb_unblock_function_t *ubf`) を実行して実行を中断
    - 中断された場合、どこで中断されたかにかかわらず即座に返る
5. GVLを取得 (これにより、他のRubyスレッドは並列に実行不可能になる)
6. `void *(*func)(void *)`の返り値 (中断された場合は0) を返す

#### UBF
- `void *(*func)(void *)` の呼び出しをキャンセルするか、キャンセルフラグを立てて実行を中断するための関数
- 他のスレッドがこのスレッドに割り込んだ場合 (Thread#kill、シグナルの送出、VM-shutdown要求など) に呼ばれる
- GVLで呼び出すことは禁止
