# Thread
## Threadクラス
- [class Thread](https://docs.ruby-lang.org/ja/2.6.0/class/Thread.html) - スレッド

### スレッドの生成
- `.fork` - スレッドを生成し、生成したスレッドでブロック内の処理を行う

### スレッドの終了
- `#join` - `self`の実行が終了するまでカレントスレッドを停止して待つ
- `#value` - `self`の実行が終了するまでカレントスレッドを停止して待ち、`self`のブロックの返り値を返す

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
- [class Thread::Mutex](https://docs.ruby-lang.org/ja/2.6.0/class/Thread=3a=3aMutex.html) - ミューテックス

### ミューテックスのロック・アンロック
- `#synchronize` - Mutexオブジェクトをロックし、ブロックを実行し、実行後アンロック

### ミューテックスのロック
- `#lock` - Mutexオブジェクトをロック

### ミューテックスのアンロック
- `#unlock` - Mutexオブジェクトをアンロック

## Thread::ConditionVariableクラス
- [class Thread::ConditionVariable](https://docs.ruby-lang.org/ja/2.6.0/class/Thread=3a=3aConditionVariable.html) - 条件変数

### 条件変数の生成
- `.new` - 条件変数を生成

### 条件変数の条件待ち
- `#wait` - 条件変数を条件待ち状態にする
  - この時、ミューテックスをアンロックし、該当のスレッドを停止する

### 条件変数への通知
- `#signal` - 条件待ちしているスレッドを一つ再開する
  - この時、ミューテックスのロックを取得し、該当のスレッドを実行状態にする

## Thread::Queueクラス
- [class Thread::Queue](https://docs.ruby-lang.org/ja/2.6.0/class/Thread=3a=3aQueue.html) - FIFOキュー

### キューの生成
- `.new` - 新しいキューを生成

### キューへのpush
- `#push` - キューの値を追加
  - この時、待機中のスレッドがいる場合は実行を再開

### キューからのpop
- `#pop` - キューから値を一つ取り出す
