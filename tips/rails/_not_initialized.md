# `#<モデル名 not initialized>`
- ActiveRecordを継承するクラスで`initialize`メソッドをオーバーライドする際に発生する

```ruby
class UserModel < ApplicationRecord
  def initialize(params)
    @foo = params.delete(:foo)
    @bar = params.delete(:bar)

    super(params)
  end
end

User.new(name: 'user', foo: 'foo', bar: 'bar')
```
