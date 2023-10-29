# class Thread::Mutex
- ミューテックス
- 並行アクセスから保護するための相互排他制御機構

```ruby
mutex = Mutex.new

Thread.fork do
  mutex.synchronize do
    do_something
  end
end
```

## ロックの獲得 / ロックの解放
- `#synchronize` - Mutexオブジェクトのロックを獲得し、ブロックを実行し、実行後ロックを解放

## ロックの獲得
- `#lock` - Mutexオブジェクトロックを獲得
- `#try_lock` - Mutexオブジェクトのロックを試み、成功した場合は真、失敗した場合は偽

## ロックの解放
- `#unlock` - Mutexオブジェクトのロックを解放

## ロックの状態の確認
- `#locked?` - Mutexオブジェクトがロックされている場合は真、そうでない場合は偽

## `module Mutex_m`
- `include Mutex_m`することでそのクラスにミューテックス機能を持たせる

```ruby
require 'mutex_m'

class Xxx
  include Mutex_m
end

xxx = Xxx.new
xxx.synchronize do
  do_something
end
```
