# Ractor
- 参照: [Ractor - Ruby's Actor-like concurrent abstraction](https://github.com/ruby/ruby/blob/master/doc/ractor.md)
- 参照: [Ruby 3.0 の Ractor を自慢したい](https://techlife.cookpad.com/entry/2020/12/26/131858)

## TL;DR
- アクターモデルを使用したスレッドセーフ並列処理機構
- `Ractor.new { expr }`で複数のRactorを生成することができ、
  ブロック内の処理`expr`は並列に実行される

### スレッド
- 各Ractorは一つ以上のスレッドを持つ
  - Ractor内のスレッドはグローバルロックを共有しており、並列実行に制限がある
  - 各Ractor同士のスレッドは並列に実行される

### オブジェクトの共有
- 各Ractor間でのオブジェクトの共有はほとんど禁止されている
  - 特殊な共有可能オブジェクトのみ共有可能
    - Immutableオブジェクト
    - Class/Moduleオブジェクト
    - その他

### メッセージ交換方式
- push型 - `Ractor#send(obj)` -> `Ractor.receive`
- pull型 - `Ractor.yield(obj)` -> `Ractor#take`

### メッセージの送信方法
- 複製 - deep copyして送信
  - `Ractor#send(obj)` - `obj`が複製される
- 移動 - shallow copyを行い、送信元ではそのオブジェクトが利用不可になる
  - `Ractor#send(obj, move: true)` - `obj`が移動する
