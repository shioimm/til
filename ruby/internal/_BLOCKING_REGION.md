# `BLOCKING_REGION`
- ブロッキング処理中に他のRubyスレッドが実行できるようにする

```c
#define BLOCKING_REGION( \
  th, \                 // ブロックする対象のスレッド
  exec, \               // 実行するブロッキング操作
  ubf, \                // ブロックを解除する関数 (UBF)
  ubfarg, \             // UBFの引数
  fail_if_interrupted \ // 割り込み時にキャンセルするかどうか
) do { \
  struct rb_blocking_region_buffer __region; \ // ブロッキング領域に入る前の状態を保存するバッファ

  // (blocking_region_begin) ブロッキング状態に入る準備を行い、アンブロッキング関数を設定する。成功するとtrueを返す
  if (blocking_region_begin(th, &__region, (ubf), (ubfarg), fail_if_interrupted) || \
    /* always return true unless fail_if_interrupted */ \
    !only_if_constant(fail_if_interrupted, TRUE)) { \ // fail_if_interruptedがtrueではないこと

    /* Important that this is inlined into the macro, and not part of \
     * blocking_region_begin - see bug #20493 */ \

    RB_VM_SAVE_MACHINE_CONTEXT(th); \             // スレッドの現在の実行状態を保存
    thread_sched_to_waiting(TH_SCHED(th), th); \  // スレッドthを待機状態に移行させる
    exec; \                                       // ブロッキング処理を実行
    blocking_region_end(th, &__region); \         // ブロッキング領域からの退出処理を行う
  }; \
} while(0)
```

