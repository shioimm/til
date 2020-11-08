# Thread
- 参照: Rubyアプリケーションプログラミング 第4章 マルチスレッド

### メインスレッドとの関係
- メインスレッドが終了すると、派生スレッドは終了する
  - スレッドの待ち合わせを行う場合は`#join`する
- 派生スレッドが終了してもメインスレッドには影響がない

## Threadクラス
- [class Thread](https://docs.ruby-lang.org/ja/2.7.0/class/Thread.html) - スレッド

### スレッドの生成
- `.start` / `.fork` - スレッドを生成し、生成したスレッドでブロック内の処理を行う

### スレッドの終了
- `#join` - `self`の実行が終了するまでカレントスレッドを停止して待つ
- `#value` - `self`の実行が終了するまでカレントスレッドを停止して待ち、`self`のブロックの返り値を返す
- `#exit` / `#kill` - スレッドの実行を終了させ、終了時に`ensure`節を実行する
  - `.exit` - カレントスレッドに対して`#exit`を呼ぶ
  - `.kill` - 指定したスレッドに対して`#kill`を呼ぶ
    - 対象のスレッドがカレントスレッドではない可能性がある

### スレッドの停止・起動
- `.stop` - カレントスレッドを`stop`状態にする
- `#wakeup` - 指定のスレッドを`stop`状態から`run`状態(run)にする
- `#run` - 指定のスレッドを`stop`状態から`run`状態(run)にする・すぐにスレッドの切り替えを行う
  - `#run` = `#wakeup` + `.pass`(他のスレッドに実行権を譲る)

### 例外の捕捉
- `#abort_on_exception = true` - 指定のスレッドに例外が発生した際、プログラムを中断させる
  - `.abort_on_exception = true` - いずれかのスレッドに例外が発生した際、プログラムを中断させる
- `#raise` - 指定のスレッドに対して例外を発生させる

### スレッドの状態
- `#status` - `self`の状態を返す
  - `run` - 実行可能/実行中
  - `sleep` - 停止中
    - `Kernel.#sleep`
    - `Thread.stop`
    - 他のスレッドの終了待ち
    - IO待ち
  - `aborting` - 終了処理中
  - `false` - 正常終了
  - `nil` - 異常終了

## Thread::Mutexクラス
- [class Thread::Mutex](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aMutex.html) - ミューテックス

```ruby
xxx = XXX.new
xxx_mutex = Mutex.new

xxx_mutex.synchronize do
  xxx.some_method
end
```

### ロックの獲得 / ロックの解放
- `#synchronize` - Mutexオブジェクトのロックを獲得し、ブロックを実行し、実行後ロックを解放

### ロックの獲得
- `#lock` - Mutexオブジェクトロックを獲得
- `#try_lock` - Mutexオブジェクトのロックを試み、成功した場合は真、失敗した場合は偽

### ロックの解放
- `#unlock` - Mutexオブジェクトのロックを解放

### Mutex_mモジュール
- [module Mutex_m](https://docs.ruby-lang.org/ja/2.7.0/class/Mutex_m.html) - Thread::Mutexクラスのモジュール版
- `include Mutex_m`することでそのクラスにミューテックス機能を持たせる

```ruby
xxx = XXX.new
xxx.extend(Mutex_m)

xxx.synchronize do
  xxx.some_method
end
```

## Syncクラス
- [class Sync](https://docs.ruby-lang.org/ja/2.7.0/class/Sync.html) - reader/writerロック
- 共有モード(SH)と排他モード(EX)を持つロック機構
  - どのスレッドもロックを獲得していない場合
    -> どのスレッドでも共有モードでロックを獲得できる
    -> どのスレッドでも排他モードでロックを獲得できる
  - あるスレッドが共有モードでロックを獲得している場合
    -> 他のスレッドは共有モードでロックを獲得できる
    -> 他のスレッドは排他モードでロックを獲得できない
  - あるスレッドが排他モードでロックを獲得している場合
    -> 他のスレッドは共有モードでロックを獲得できない
    -> 他のスレッドは排他モードでロックを獲得できない

```ruby
xxx = XXX.new
xxx_sync = Sync.new

xxx_sync.synchronize(:EX) do
  xxx.some_method
end

xxx_sync.synchronize(:SH) do
  xxx.other_method
end
```

### ロックの獲得 / ロックの解放
- `#synchronize` - 指定のモードでロックを獲得し、ブロックを実行し、実行後ロックを解放

### ロック
- `#lock` - 指定のモードでロックを獲得
- `#try_lock` - 指定のモードでロックを試み、成功した場合は真、失敗した場合は偽

### ロックの解放
- `#unlock` - 指定のモードでロックを解放

### Sync_mモジュール
- [module Sync_m](https://docs.ruby-lang.org/ja/2.7.0/class/Sync_m.html) - Syncクラスのモジュール版

```ruby
xxx = XXX.new
xxx.extend(Sync_m)

xxx.synchronize(:EX) do
  xxx.some_method
end

xxx.synchronize(:SH) do
  xxx.other_method
end
```

## Thread::ConditionVariableクラス
- [class Thread::ConditionVariable](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aConditionVariable.html) - 条件変数

### 条件変数の生成
- `.new` - 条件変数を生成

### 条件変数の条件待ち
- `#wait` - 引数に渡したミューテックスのロックを解放し、カレントスレッドを`stop`状態にする

### 条件変数への通知
- `#signal` / `#broadcast` - `wait`時に解放したミューテックスのロックを獲得し、スレッドを`run`状態にする
  - `#signal` - 一つのスレッドが対象
  - `#broadcast` - すべてのスレッドが対象

## Monitorクラス
- [class Monitor](https://docs.ruby-lang.org/ja/2.7.0/class/Monitor.html) - スレッドの同期機構としてのモニター機能
- Mutexに似ているがネストしたロックをサポートしており、条件変数の機能を兼ね備える

### Monitorオブジェクトの生成
- `.new` - Monitorオブジェクトを生成

### 条件変数の取得
- `#new_cond` - Monitorオブジェクトに関連づけられた条件変数を返す
  - Monitorオブジェクトと結びついているため`wait`にミューテックスを渡す必要がない

### 条件変数の条件待ち
- `#wait` - Monitorオブジェクトのロックを解放し、カレントスレッドを`stop`状態にする

### 条件変数への通知
- `#signal` / `#broadcast` - `wait`時に解放したMonitorオブジェクトのロックを獲得し、スレッドを`run`状態にする
  - `#signal` - 一つのスレッドが対象
  - `#broadcast` - すべてのスレッドが対象

## Thread::Queueクラス
- [class Thread::Queue](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aQueue.html) - FIFOキュー

### キューの生成
- `.new` - 新しいキューを生成

### キューへのpush
- `#enq` / `#push` - キューの値を追加
  - 呼び出し元のスレッドが`stop`状態の場合(空のキューに値を追加する場合)は`run`状態にする

### キューからのpop
- `#deq` / `#pop` - キューから値を一つ取り出す
  - キューが空の時、新しいキューの値が追加されるまで呼出元のスレッドは`stop`状態になる
