## レキシカルスコープ(見たままのスコープ)
```rb
# hoge.rb

class Hoge
  def initialize(&block)
    @block = block
  end

  def call_block
    @block.call
  end
end
```

```ruby
val = 'a'

require_relative './hoge'

hoge = Hoge.new do
  val = val * 2
end

val = 'b'

p hoge.call_block
p hoge.call_block
p hoge.call_block
p hoge.call_block

val = 'c'

p hoge.call_block

# =>"bb"
# =>"bbbb"
# =>"bbbbbbbb"
# =>"bbbbbbbbbbbbbbbb"
# =>"cc"
```

- ブロックは「状態を持った手続き(関数)」
- ブロックの内部は`call`が呼ばれるまで実行されない
  - `call`が呼ばれる直前に定義した変数が使用されている
