# マッチャ
#### `satisfy`
- ブロックの中でsubjectの返り値に対して true / false を確認することができる

```ruby
subject { number } # number = 10

is_expected.to     satisfy { |v| v.modulo(5).zero? }
is_expected.not_to satisfy { |v| v.modulo(3).zero? }
```

- 参照: [satisfy matcher](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher)
