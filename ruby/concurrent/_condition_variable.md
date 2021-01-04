# class Thread::ConditionVariable
- [class Thread::ConditionVariable](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aConditionVariable.html) - 条件変数

## 条件変数の生成
- `.new` - 条件変数を生成

## 条件変数の条件待ち
- `#wait` - 引数に渡したミューテックスのロックを解放し、カレントスレッドを`stop`状態にする

## 条件変数への通知
- `#signal` / `#broadcast` - `wait`時に解放したミューテックスのロックを獲得し、スレッドを`run`状態にする
  - `#signal` - 一つのスレッドが対象
  - `#broadcast` - すべてのスレッドが対象
