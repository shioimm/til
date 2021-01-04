# class Thread::Queue
- [class Thread::Queue](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aQueue.html) - FIFOキュー

## キューの生成
- `.new` - 新しいキューを生成

## キューへのpush
- `#enq` / `#push` - キューの値を追加
  - 呼び出し元のスレッドが`stop`状態の場合(空のキューに値を追加する場合)は`run`状態にする

## キューからのpop
- `#deq` / `#pop` - キューから値を一つ取り出す
  - キューが空の時、新しいキューの値が追加されるまで呼出元のスレッドは`stop`状態になる
