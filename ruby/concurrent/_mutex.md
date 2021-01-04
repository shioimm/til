# class Thread::Mutex
- [class Thread::Mutex](https://docs.ruby-lang.org/ja/2.7.0/class/Thread=3a=3aMutex.html) - ミューテックス

```ruby
xxx = XXX.new
xxx_mutex = Mutex.new

xxx_mutex.synchronize do
  xxx.some_method
end
```

## ロックの獲得 / ロックの解放
- `#synchronize` - Mutexオブジェクトのロックを獲得し、ブロックを実行し、実行後ロックを解放

## ロックの獲得
- `#lock` - Mutexオブジェクトロックを獲得
- `#try_lock` - Mutexオブジェクトのロックを試み、成功した場合は真、失敗した場合は偽

## ロックの解放
- `#unlock` - Mutexオブジェクトのロックを解放

## module Mutex_m
- [module Mutex_m](https://docs.ruby-lang.org/ja/2.7.0/class/Mutex_m.html) - Thread::Mutexクラスのモジュール版
- `include Mutex_m`することでそのクラスにミューテックス機能を持たせる

```ruby
xxx = XXX.new
xxx.extend(Mutex_m)

xxx.synchronize do
  xxx.some_method
end
```
