## Validation

### boolean型のカラムに対してpresenceバリデーションをかけたい
- boolean型のカラムに対して`presence`ヘルパーを使用すると、
値が`false`の場合に`valid? # => false`になる
- 代わりに`inclusion`ヘルパーと`:in`オプションを使用する
```ruby
# 属性hogeがtrue || falseであること(値を含んでいることによって存在を担保する)
validates :hoge, inclusion: { in: [true, false] }
```
- 参照: [Active Record バリデーション](https://railsguides.jp/active_record_validations.html#inclusion)
