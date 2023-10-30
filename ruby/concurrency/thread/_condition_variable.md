# class Thread::ConditionVariable
- 条件変数
- 排他領域で処理を行っているスレッド同士がお互い非同期に通信し合う手段を提供する

```ruby
mutex = Mutex.new
cv = ConditionVariable.new

thread1 = Thread.start do
  mutex.synchronize do # --- 排他領域 ----
    while 条件が満たされない間
      cv.wait(mutex) # 条件変数の待機
    end

    # whileから抜けると後続の処理が行われる
  end # -----------------------------------
end

thread2 = Thread.start do
  mutex.synchronize do # ---- 排他領域 ----
    do_something # 条件を満たす操作
    cv.signal
  end # -----------------------------------
end
```

## 条件変数の生成
- `.new` - 条件変数を生成

## 条件変数の待機
- `#wait` - 指定のMutexオブジェクトのロックを解放し、カレントスレッドを`sleep`状態にする

## 条件変数への通知
- `#signal` / `#broadcast` - `wait`時に解放したMutexオブジェクトのロックを再び獲得し、スレッドを`run`状態にする
  - `#signal` - 一つのスレッドが対象
  - `#broadcast` - すべてのスレッドが対象
