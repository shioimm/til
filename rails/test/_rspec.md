# RSpec
## マッチャ
### `satisfy`
- 参照: [satisfy matcher](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher)
- ブロックの中でsubjectの返り値に対して`true / false`を確認することができる
```ruby
subject { number } # number = 10

is_expected.to satisfy { |v| v.modulo(5).zero? }
is_expected.not_to satisfy { |v| v.modulo(3).zero? }
```

## モック
#### `allow`
- 対象のオブジェクト・メソッド・返り値を指定する

#### `double`
- 返り値の代替となるオブジェクト
  - メソッドの代替として任意の値を返すハッシュを渡すことができる

```ruby
let(:xxx_rest_client_instance) { double('Xxx::Rest::Client', to_jwt: 'token') }

before do
  allow(Xxx::Rest::Client).to receive(:new).and_return xxx_rest_client_instance
end

# 以降、xxx_rest_client_instanceに対してto_jwtを呼ぶと'token'を返すようになる
```
