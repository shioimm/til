# class Sync
- reader/writerロック
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

## ロックの獲得 / ロックの解放
- `#synchronize` - 指定のモードでロックを獲得し、ブロックを実行し、実行後ロックを解放

## ロック
- `#lock` - 指定のモードでロックを獲得
- `#try_lock` - 指定のモードでロックを試み、成功した場合は真、失敗した場合は偽

### ロックの解放
- `#unlock` - 指定のモードでロックを解放

## `module Sync_m`

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
