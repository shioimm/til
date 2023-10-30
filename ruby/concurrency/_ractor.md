# Ractor
- アクターモデルを使用したスレッドセーフ並列処理機構
- `Ractor.new { expr }`で複数のRactorを生成することができ、
  ブロック内の処理`expr`は並列に実行される

### スレッド
- 各Ractorは一つ以上のスレッドを持つ
  - Ractor内のスレッドは各Ractorに属するグローバルロックを共有しており、並列実行に制限がある
  - 各Ractor同士のスレッドは並列に実行される

### メッセージ交換方式
- push型(sender knows receiver) - `Ractor#send(obj)` -> `Ractor.receive`
- pull型(receiver knows sender) - `Ractor.yield(obj)` -> `Ractor#take`

### メッセージ
- メッセージ = Rubyのオブジェクト
- オブジェクトには共有可能オブジェクトと不可能オブジェクトがある
  - 共有可能オブジェクトをメッセージとして転送すると、参照が送られる
    - 共有可能オブジェクトへのアクセスは必ず排他制御される
  - 共有不可能オブジェクトをメッセージとして転送すると、複製される
    - 共有不可能オブジェクトには移動ができるものもある

#### 共有可能オブジェクト
- Immutableオブジェクト
- Class/Moduleオブジェクト
- その他

####  共有不可能オブジェクト
- 共有可能オブジェクト以外

### メッセージの送信方法
- 参照
  - 共有可能オブジェクトは参照を送信
- 複製
  - deep copyして送信
  - `Ractor#send(obj)` - `obj`が複製される
- 移動
  - shallow copyして送信、送信元ではそのオブジェクトが利用不可になる
  - `Ractor#send(obj, move: true)` - `obj`が移動する

## Ractorの生成
```ruby
Ractor.new do
  # ブロック内の処理が並行に実行される
end

# Ractorのブロック内のコンテキストはRactorを生成したコンテキストから隔離される
```

```ruby
# Ractor.new に渡される引数はそのRactorへのincoming message

Ractor.new 'hello' { |msg|
  msg #=> 'hello'
}

Ractor.new {
  Ractor.recv #=> 'hello'
}.send('hello')
```

```ruby
# ブロックの返り値はそのRactorからのoutgoing message

Ractor.new {
  'hello'
}.take #=> 'hello'

Ractor.new {
  Ractor.yield 'hello'
}.take #=> 'hello'
```

## Ractor間のメッセージ送受信
- 各Ractorは、それぞれincoming port、outgoing portを持つ
  - incoming portにはincoming queue(無限サイズのキュー)が接続されている
  - portはRactorが終了したり、`Ractor#close_incoming` / `Ractor#close_outgoing`を呼ばれるとクローズする

### push型通信(sender knows receiver)
```ruby
x = Ractor.new do
  # 2. Ractor xが自身のincoming queueから受信したメッセージ'hello'を取り出す
  # (incoming queue が空ならブロックする)
  msg = Ractor.recv
end

# 1. メインRactorがRactor xのincoming port(incoming queue)へメッセージ'hello'を送信
x.send('hello')

# 3. メインRactorがRactor xのoutgoing portからメッセージ'hello'を受信
r.take #=> 'hello'
```

```ruby
# 1. 実引数'hello'をメッセージとしてincoming port(incoming queue)へ送信
x = Ractor.new 'hello' do |msg|
  # 2. incoming queueから受信したメッセージ'hello'を仮引数msgとして取り出す

  # 3. outgoing portへメッセージ'hello'を送信(ブロックの返り値)
  msg
end

# 4. メインRactorがRactor xのoutgoing portからメッセージ'hello'を受信
r.take #=> 'hello'
```

### pull型通信(receiver knows sender)
```ruby
x = Ractor.new do
  # 1. outgoing portへメッセージ'hello'を送信(ブロックの返り値)
  'hello'
end

# 2. メインRactorがRactor xのoutgoing portからメッセージ'hello'を受信
x.take #=> 'hello'
```

```ruby
x = Ractor.new do
  # 1. outgoing portへメッセージ'hello'を送信
  Ractor.yield 'hello'
end

# 2. メインRactorがRactor xのoutgoing portからメッセージ'hello'を受信
x.take #=> 'hello'
```

### 複数のRactor からメッセージを受信する
- `Ractor.select(*ractors)`を用いて複数のRactorからの`take`を待つことができる
  - メッセージを受信したRactorと、Ractorが受信したメッセージを返す

## 参照
- [Ractor - Ruby's Actor-like concurrent abstraction](https://github.com/ruby/ruby/blob/master/doc/ractor.md)
- [ruby/ractor.ja.md](https://github.com/ko1/ruby/blob/ractor/ractor.ja.md)
- [Ruby 3.0 の Ractor を自慢したい](https://techlife.cookpad.com/entry/2020/12/26/131858)
